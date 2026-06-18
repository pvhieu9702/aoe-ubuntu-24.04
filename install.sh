#!/bin/bash

set -e

GAME_ZIP_URL="https://github.com/pvhieu9702/aoe-ubuntu-24.04/raw/refs/heads/master/game/AOEFULL.zip"

GAME_DIR_LOCAL="./game"
GAME_ZIP="$GAME_DIR_LOCAL/AOEFULL.zip"

WINE_PREFIX="$HOME/.wine-aoe"
GAME_DIR="$WINE_PREFIX/drive_c/Program Files/AOEFULL"
DESKTOP_FILE="$HOME/.local/share/applications/aoe-ror.desktop"

echo "=== Install dependencies ==="

sudo dpkg --add-architecture i386 || true
sudo mkdir -pm755 /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/winehq-archive.key ]; then
    sudo wget -O /etc/apt/keyrings/winehq-archive.key \
    https://dl.winehq.org/wine-builds/winehq.key
fi

if [ ! -f /etc/apt/sources.list.d/winehq-noble.sources ]; then
    sudo wget -NP /etc/apt/sources.list.d/ \
    https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
fi

sudo apt update
sudo apt install -y --install-recommends winehq-stable winetricks unzip curl

echo "=== Wine version ==="
wine --version

echo "=== Create Wine 32-bit prefix ==="

export WINEARCH=win32
export WINEPREFIX="$WINE_PREFIX"

if [ ! -d "$WINE_PREFIX" ]; then
    wineboot --init
fi

echo "=== Install DirectPlay ==="

WINEPREFIX="$WINE_PREFIX" winetricks -q directplay

echo "=== Download game zip ==="

mkdir -p "$GAME_DIR_LOCAL"

if [ ! -f "$GAME_ZIP" ]; then
    curl -L --fail --progress-bar "$GAME_ZIP_URL" -o "$GAME_ZIP"
else
    echo "Game zip already exists: $GAME_ZIP"
fi

echo "=== Extract game ==="

if [ ! -f "$GAME_ZIP" ]; then
    echo "Game zip not found: $GAME_ZIP"
    exit 1
fi

rm -rf "$GAME_DIR"
mkdir -p "$GAME_DIR"

unzip -q "$GAME_ZIP" -d "$GAME_DIR"

echo "=== Configure firewall ==="

if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 2300:2400/udp
    sudo ufw allow 2300:2400/tcp
    sudo ufw allow 47624/tcp
    sudo ufw allow from 192.168.0.0/16
    sudo ufw reload || true
fi

echo "=== Create desktop launcher ==="

mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Age of Empires - Rise of Rome
Comment=Age of Empires Rise of Rome
Exec=bash -c 'export WINEPREFIX=\$HOME/.wine-aoe && cd "\$HOME/.wine-aoe/drive_c/Program Files/AOEFULL" && wine Empiresxhd.exe'
Icon=applications-games
Terminal=false
Categories=Game;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" || true
fi

echo "=== Done ==="
echo "Run game from application menu:"
echo "Age of Empires - Rise of Rome"
echo
echo "Or manually:"
echo "cd \"$GAME_DIR\""
echo "WINEPREFIX=\"$WINE_PREFIX\" wine Empiresxhd.exe"