ln $HOME/dotfiles/config/fish/ $HOME/.config/ -sf
ln $HOME/dotfiles/config/starship.toml $HOME/.config/ -sf
ln $HOME/dotfiles/config/kitty/ $HOME/.config/ -sf
ln $HOME/dotfiles/.aliases $HOME/.aliases -sf
ln $HOME/dotfiles/config/nvim/ $HOME/.config -sf
ln $HOME/dotfiles/config/lvim/ $HOME/.config/lvim -sf

# Plasma theme auto-switch systemd units
mkdir -p ~/.config/systemd/user

ln -sf "$HOME/dotfiles/config/systemd/user/plasma-theme.service" ~/.config/systemd/user/plasma-theme.service
ln -sf "$HOME/dotfiles/config/systemd/user/plasma-theme.timer" ~/.config/systemd/user/plasma-theme.timer
sudo ln -sf "$HOME/dotfiles/scripts/plasma-theme-resume" /usr/lib/systemd/system-sleep/plasma-theme-resume
sudo ln -s ~/dotfiles/services/* /etc/systemd/system/

systemctl --user daemon-reexec
systemctl --user enable --now plasma-theme.timer
sudo systemctl enable --now conservation-mode.service

mkdir /etc/wireguard
sudo chown $USER /etc/wireguard
sudo chmod 755 /etc/wireguard

git config --global core.excludesfile ~/dotfiles/config/.gitignore_global
