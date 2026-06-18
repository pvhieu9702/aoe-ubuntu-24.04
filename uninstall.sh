sudo apt remove --purge -y winehq-stable wine-stable wine-stable-amd64 wine-stable-i386 && \
sudo apt autoremove -y && \
rm -rf ~/.wine ~/.wine-aoe ~/.cache/winetricks ~/.local/share/winetricks && \
rm -f ~/.local/share/applications/aoe-ror.desktop && \
sudo rm -f /etc/apt/sources.list.d/winehq-*.sources && \
sudo rm -f /etc/apt/keyrings/winehq-archive.key && \
sudo apt update