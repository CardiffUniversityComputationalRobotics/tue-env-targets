#! /usr/bin/env bash

DIRECTORY='/opt/Qt'
if [ ! -d "$DIRECTORY" ]
then
    cucr-install-pipe wget http://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run -O /tmp/qt-open-source-installer
    cucr-install-pipe chmod +x /tmp/qt-open-source-installer

    cucr-install-tee ""
    cucr-install-echo "Choose $DIRECTORY as install directory!"
    cucr-install-tee ""

    cucr-install-pipe sudo /tmp/qt-open-source-installer
fi

# Shortcut
if [ -f ~/.local/share/applications/org.qt-project.qtcreator.desktop ] && ! grep -qi cucr_robotics ~/.local/share/applications/org.qt-project.qtcreator.desktop
then
    cucr-install-debug "Creating back-up of QtCreator desktop file"
    cucr-install-pipe mv -f ~/.local/share/applications/org.qt-project.qtcreator.desktop ~/.local/share/applications/org.qt-project.qtcreator.desktop.bk
fi

cucr-install-cp shortcut/org.qt-project.qtcreator.desktop ~/.local/share/applications/org.qt-project.qtcreator.desktop
