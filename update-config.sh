#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options
printf "\e[36m[$0]: 3. Copying\e[97m\n"
ask=false

for i in $(find .config/ -mindepth 1 -maxdepth 1 ! -name 'ags' ! -name 'fish' ! -name 'hypr' -exec basename {} \;); do
  i=".config/$i"
  echo "[$0]: Found target: $i"
  if [ -d "$i" ];then v rsync -av --delete "$i/" "$HOME/$i/"
  elif [ -f "$i" ];then v rsync -av "$i" "$HOME/$i"
  fi
done

# For AGS
v rsync -av --delete --exclude '/user_options.js' .config/ags/ "$HOME"/.config/ags/

# For Hyprland
v rsync -av --delete --exclude '/custom' .config/hypr/ "$HOME"/.config/hypr/
t="$HOME/.config/hypr/custom"
if [ -d $t ];then
  echo -e "\e[34m[$0]: \"$t\" already exists, will not do anything.\e[0m"
else
  echo -e "\e[33m[$0]: \"$t\" does not exist yet.\e[0m"
  v rsync -av --delete .config/hypr/custom/ $t/
fi

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