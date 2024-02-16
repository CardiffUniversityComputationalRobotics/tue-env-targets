#! /usr/bin/env bash

# Get script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create MEGA DIR is not exists
DATA_DIR="$HOME/MEGA"
if [ ! -d "$DATA_DIR" ]
then
    # Create data dir
    cucr-install-echo "Creating MEGA dir in home"
    mkdir -p "$DATA_DIR"
fi

# Setup mega rc file
if [ ! -f "$HOME/.megarc" ]
then
    # Create .megarc file in $HOME
    cucr-install-echo "Copying megarc file to home"
    cp "$DIR"/.megarc "$HOME"/.megarc

    cucr-install-echo "Please type the MEGA password of the amigoathome@gmail.com account"
    read -r -s -p password: passwd

    cucr-install-echo "Adding password to .megarc file"
    echo "Password = $passwd" >> "$HOME"/.megarc

    cucr-install-echo "Setting permissions to .megarc file"
    chmod 640 ~/.megarc
fi


# Setup the sync service
if [ ! -f "/etc/systemd/system/mega.timer" ]
then
    # Create mega service
    cucr-install-echo "Copying mega service files to /etc/systemd/system"

    cucr-install-pipe sudo cp "$DIR"/mega.service /etc/systemd/system/
    cucr-install-pipe sudo cp "$DIR"/mega.timer /etc/systemd/system/

    # Reload and enable
    cucr-install-pipe sudo systemctl daemon-reload
    cucr-install-pipe sudo systemctl start mega.service
    cucr-install-pipe sudo systemctl enable mega.service
fi

