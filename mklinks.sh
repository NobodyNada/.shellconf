#!/bin/sh

if test -d ~/./vim; then
    echo "error: ~/.vim already exists" 1>&2
    exit 1
fi
ln -s ~/.shellconf/vim ~/.vim
ln -s ~/.shellconf/vimrc ~/.vimrc
mkdir -p ~/.config
if test -d ~/.config/fish; then
    echo "error: ~/.config/fish already exists" 1>&2
    exit 1
fi
ln -s ~/.shellconf/fish ~/.config/fish
