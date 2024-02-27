#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options
printf "\e[36m[$0]: 3. Copying\e[97m\n"
ask=false

# In case ~/.local/bin does not exists
# v mkdir -p "$HOME/.local/bin" "$HOME/.local/share"

# `--delete' for rsync to make sure that
# original dotfiles and new ones in the SAME DIRECTORY
# (eg. in ~/.config/hypr) won't be mixed together

for i in .config/*
do
  echo "[$0]: Found target: $i"
  if [ -d "$i" ];then v rsync -av --delete "$i/" "$HOME/$i/"
  elif [ -f "$i" ];then v rsync -av "$i" "$HOME/$i"
  fi
done

# target="$HOME/.config/hypr/colors.conf"
# test -f $target || { \
#   echo -e "\e[34m[$0]: File \"$target\" not found.\e[0m" && \
#   v cp "$HOME/.config/hypr/colors_default.conf" $target ; }

# some foldes (eg. .local/bin) should be processed seperately to avoid `--delete' for rsync,
# since the files here come from different places, not only about one program.
v rsync -av ".local/bin/" "$HOME/.local/bin/"

# Prevent hyprland from not fully loaded
sleep 1
try hyprctl reload