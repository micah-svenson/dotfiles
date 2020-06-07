#!/bin/zsh

# sync .config
ln -sv ~/dotfiles/.config ~

# bashrc
ln -sv ~/dotfiles/.bashrc ~

# bash_profile (points to bashrc)
ln -sv ~/dotfiles/.bash_profile ~

# global git config
ln -sv ~/dotfiles/.gitconfig ~

# gtk settings (modified by lx-appearance)
ln -sv ~/dotfiles/.gtkrc-2.0 ~

# task warrior rc
ln -sv ~/dotfiles/.taskrc ~

# xinitrc - starts picom and i3
ln -sv ~/dotfiles/.xinitrc ~

# Xresources - sets colors right now
ln -sv ~/dotfiles/.Xresources ~

# .zsh rc file
ln -sv ~/dotfiles/.zshrc ~





