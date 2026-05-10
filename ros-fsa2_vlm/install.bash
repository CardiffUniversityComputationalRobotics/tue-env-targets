#!/usr/bin/env bash
# tue-env target: ros-fsa2_vlm
#
# Workstation-level setup for fsa2_vc's VLM seam (operator-as-task-planner
# v2 architecture, Phase 6+). Side-effects only; no install.yaml — same
# pattern as zeromq / sublime3 in this repo.
#
# Usage on a fresh Ubuntu workstation (assumes tue-env is set up + this
# targets repo is at ~/ros/humble/.env/targets/):
#
#     cucr-get install ros-fsa2_vlm
#
# Companion Mac-side instructions live in
# fsa2_vc/docs/macbook_ollama_setup.md — the Mac must already be running
# Ollama with the chosen model + Remote Login enabled before this script
# can finish step 2.
#
# What it does (all idempotent):
#   1. apt-installs autossh + libnss-mdns + avahi-daemon + curl +
#      openssh-client.
#   2. Generates an SSH key if missing; copies to the Mac via ssh-copy-id
#      (one interactive step — Mac password prompt happens once).
#   3. Confirms Ollama is installed + the chosen model is pulled on the
#      Mac; pulls if missing.
#   4. Installs local Ollama as the fallback backend + pulls the same
#      model locally (so vision-bearing calls degrade cleanly when the
#      Mac is unreachable). Skip with FSA2_SKIP_LOCAL_OLLAMA=1.
#   5. Writes + enables a systemd-user service running autossh — Mac's
#      127.0.0.1:11434 forwarded to local 127.0.0.1:11500. Restarts
#      automatically on network/sleep/wake.
#   6. Writes ~/.config/fsa2/vlm.env with FSA2_VLM_* env overrides; adds
#      a source-line to ~/.bashrc so new shells pick it up.
#   7. Smoke-tests the tunnel.
#
# Configuration (all env vars optional; defaults shown):
#   FSA2_MAC_USER           ioannis
#   FSA2_MAC_HOST           Ioanniss-MacBook-Air.local
#   FSA2_VLM_MODEL          qwen2.5vl:7b
#   FSA2_LOCAL_TUNNEL_PORT  11500
#   FSA2_SKIP_LOCAL_OLLAMA  unset

# NOTE: no `set -euo pipefail`. tue-env *sources* install.bash from
# cucr-install-impl.bash; the strict-mode settings would leak back into
# the caller (its `$DEBUG` and friends are intentionally unset). Match
# the existing target pattern (zeromq, ros-fsa2_fr3): plain bash with
# explicit checks + `cucr-install-error` for fatal failures.

MAC_USER="${FSA2_MAC_USER:-ioannis}"
MAC_HOST="${FSA2_MAC_HOST:-Ioanniss-MacBook-Air.local}"
MODEL="${FSA2_VLM_MODEL:-qwen2.5vl:7b}"
LOCAL_TUNNEL_PORT="${FSA2_LOCAL_TUNNEL_PORT:-11500}"

log()  { printf '[ros-fsa2_vlm] %s\n' "$*"; }
warn() { printf '[ros-fsa2_vlm] WARN: %s\n' "$*" >&2; }
die()  {
    # cucr-install-error is tue-env's fatal-error helper; it prints +
    # aborts the install cleanly. Use that if available; otherwise fall
    # back to stderr + `return` (NOT exit — exit would kill the caller
    # because tue-env sources this script).
    if command -v cucr-install-error >/dev/null 2>&1; then
        cucr-install-error "[ros-fsa2_vlm] $*"
    else
        printf '[ros-fsa2_vlm] ERROR: %s\n' "$*" >&2
        return 1
    fi
}

# Run a command on the Mac with Homebrew's PATH prepended. Non-interactive
# SSH sessions on macOS don't source shell profiles, so Homebrew binaries
# (Apple Silicon: /opt/homebrew/bin; Intel: /usr/local/bin) aren't on PATH
# by default. Wrap every remote call through this helper so `ollama` etc.
# resolve regardless of the Mac's architecture.
remote() {
    ssh "$MAC_USER@$MAC_HOST" \
        "export PATH=/opt/homebrew/bin:/usr/local/bin:\$PATH; $*"
}

# ---- 1. apt prerequisites ----------------------------------------------
log "step 1/7: apt prerequisites"
need=()
for pkg in autossh libnss-mdns avahi-daemon openssh-client curl; do
    dpkg -s "$pkg" >/dev/null 2>&1 || need+=("$pkg")
done
if [ ${#need[@]} -gt 0 ]; then
    log "installing: ${need[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${need[@]}"
else
    log "all packages present"
fi

# ---- 2. SSH key + Mac auth ---------------------------------------------
log "step 2/7: SSH key + Mac auth"
if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
    log "generating ~/.ssh/id_ed25519"
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
fi

getent hosts "$MAC_HOST" >/dev/null \
    || die "$MAC_HOST does not resolve via mDNS — check Avahi/Bonjour."

if ! ssh -o BatchMode=yes -o ConnectTimeout=5 \
        "$MAC_USER@$MAC_HOST" 'true' 2>/dev/null; then
    log "passwordless SSH not yet set up; running ssh-copy-id"
    log "(you'll be asked for the Mac password ONCE)"
    ssh-copy-id "$MAC_USER@$MAC_HOST"
fi
log "passwordless SSH to $MAC_USER@$MAC_HOST OK"

# ---- 3. Mac-side Ollama + model ----------------------------------------
log "step 3/7: Mac-side Ollama"
if ! remote 'command -v ollama >/dev/null'; then
    die "ollama is not installed on the Mac.
        Run on the Mac (in its own terminal):
            brew install --cask ollama && brew services start ollama
        Then re-run cucr-get install ros-fsa2_vlm."
fi

mac_models=$(remote 'ollama list' 2>/dev/null | awk 'NR>1 {print $1}')
if ! printf '%s\n' "$mac_models" | grep -qx "$MODEL"; then
    log "pulling $MODEL on the Mac (~5 GB; takes several minutes)..."
    remote "ollama pull $MODEL" 2>&1 | sed 's/^/[mac] /'
fi
log "Mac model present: $MODEL"

# ---- 4. Local Ollama (fallback backend) --------------------------------
log "step 4/7: local Ollama (fallback)"
if [ "${FSA2_SKIP_LOCAL_OLLAMA:-}" = "1" ]; then
    log "FSA2_SKIP_LOCAL_OLLAMA=1; skipping"
else
    # Always run the install script — it's idempotent + upgrades an
    # existing install. Needed because older Ollama versions can't
    # pull newer models (e.g. qwen3-vl needs ~0.6+; pre-0.6 fails with
    # HTTP 412 "requires a newer version of Ollama").
    log "installing / upgrading local Ollama"
    curl -fsSL https://ollama.com/install.sh | sh \
        || die "local Ollama install/upgrade failed"
    sudo systemctl enable --now ollama 2>/dev/null || true
    # Give the daemon a moment to come back after upgrade-induced
    # restart.
    sleep 2

    local_models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    if ! printf '%s\n' "$local_models" | grep -qx "$MODEL"; then
        log "pulling $MODEL locally (~5 GB; takes several minutes)..."
        ollama pull "$MODEL" \
            || die "ollama pull $MODEL failed. Check 'ollama --version' (need ~0.6+ for qwen3-vl)."
        # `ollama pull` has been observed to exit 0 even on 412 errors.
        # Re-check the listing to be sure.
        local_models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
        printf '%s\n' "$local_models" | grep -qx "$MODEL" \
            || die "ollama pull $MODEL reported success but $MODEL isn't in 'ollama list'. Check 'ollama --version' (need ~0.6+) + retry."
    fi
    log "local Ollama has $MODEL"
fi

# ---- 5. systemd-user tunnel --------------------------------------------
log "step 5/7: systemd-user tunnel"
unit_dir="$HOME/.config/systemd/user"
mkdir -p "$unit_dir"
cat > "$unit_dir/ollama-tunnel.service" <<UNIT
[Unit]
Description=SSH tunnel to MacBook Ollama (fsa2_vc VLM primary backend)
After=network-online.target
Wants=network-online.target

[Service]
Environment="AUTOSSH_GATETIME=0"
Environment="AUTOSSH_POLL=60"
ExecStart=/usr/bin/autossh -M 0 -N \\
    -o ServerAliveInterval=30 \\
    -o ServerAliveCountMax=3 \\
    -o ExitOnForwardFailure=yes \\
    -o StrictHostKeyChecking=accept-new \\
    -L ${LOCAL_TUNNEL_PORT}:127.0.0.1:11434 \\
    ${MAC_USER}@${MAC_HOST}
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
UNIT
systemctl --user daemon-reload
systemctl --user enable --now ollama-tunnel.service

# Wait briefly for the tunnel to come up.
for _ in 1 2 3 4 5; do
    sleep 1
    curl -sf --max-time 2 \
        "http://127.0.0.1:${LOCAL_TUNNEL_PORT}/api/tags" >/dev/null \
        && break
done

# ---- 6. fsa2_vc env config ---------------------------------------------
log "step 6/7: writing ~/.config/fsa2/vlm.env"
env_dir="$HOME/.config/fsa2"
mkdir -p "$env_dir"
cat > "$env_dir/vlm.env" <<ENV
# Auto-generated by ros-fsa2_vlm/install.bash on $(date -Iseconds).
# Pins the C++ VlmClient (fsa2_vc) to this workstation's chosen
# primary/fallback endpoints + active model. Source from your shell rc
# to apply.
export FSA2_VLM_PRIMARY_BASE_URL=http://127.0.0.1:${LOCAL_TUNNEL_PORT}/v1
export FSA2_VLM_PRIMARY_MODEL=${MODEL}
export FSA2_VLM_PRIMARY_LABEL=macbook
export FSA2_VLM_FALLBACK_BASE_URL=http://127.0.0.1:11434/v1
export FSA2_VLM_FALLBACK_MODEL=${MODEL}
export FSA2_VLM_FALLBACK_LABEL=linux-local
ENV

rc="$HOME/.bashrc"
marker='# fsa2_vc VLM env (managed by ros-fsa2_vlm)'
if [ -f "$rc" ] && ! grep -qF "$marker" "$rc"; then
    cat >> "$rc" <<RC

$marker
[ -f "$env_dir/vlm.env" ] && source "$env_dir/vlm.env"
RC
    log "appended source-line to $rc"
fi

# ---- 7. Smoke ----------------------------------------------------------
log "step 7/7: smoke test"
systemctl --user is-active --quiet ollama-tunnel.service \
    || die "tunnel service not active. Check: systemctl --user status ollama-tunnel.service"
if curl -fs --max-time 5 "http://127.0.0.1:${LOCAL_TUNNEL_PORT}/api/tags" \
       | grep -q "$MODEL"; then
    log "OK: tunnel serves $MODEL"
else
    warn "tunnel up but /api/tags didn't list $MODEL — investigate"
fi

cat <<DONE

==========================================================================
ros-fsa2_vlm installation complete.

  primary  endpoint:  macbook       http://127.0.0.1:${LOCAL_TUNNEL_PORT}/v1   model=$MODEL
  fallback endpoint:  linux-local   http://127.0.0.1:11434/v1                  model=$MODEL

Env config:  $env_dir/vlm.env
  (auto-sourced from ~/.bashrc on new shells; source it now with:
   source $env_dir/vlm.env)

Verify with the C++ smoketest after building fsa2_core:
  ros2 run fsa2_core vlm_client_smoketest \\
    \$(ros2 pkg prefix fsa2_core)/share/fsa2_core/config/action_templates.yaml \\
    \$(ros2 pkg prefix fsa2_fr3)/share/fsa2_fr3/config/scenarios/sim_default_world.yaml
==========================================================================
DONE