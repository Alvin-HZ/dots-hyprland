#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/environment-variables
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options

ask=false

printf "\e[36m[$0]: 2. Copying + Configuring\e[0m\n"

# In case some folders does not exists
v mkdir -p $XDG_BIN_HOME $XDG_CACHE_HOME $XDG_CONFIG_HOME $XDG_DATA_HOME

# `--delete' for rsync to make sure that
# original dotfiles and new ones in the SAME DIRECTORY
# (eg. in ~/.config/hypr) won't be mixed together

# MISC (For .config/* but not fish, not Hyprland)
case $SKIP_MISCCONF in
true) sleep 0 ;;
*)
	for i in $(find .config/ -mindepth 1 -maxdepth 1 ! -name 'fish' ! -name 'hypr' -exec basename {} \;); do
		#      i=".config/$i"
		echo "[$0]: Found target: .config/$i"
		if [ -d ".config/$i" ]; then
			v rsync -av --delete ".config/$i/" "$XDG_CONFIG_HOME/$i/"
		elif [ -f ".config/$i" ]; then
			v rsync -av ".config/$i" "$XDG_CONFIG_HOME/$i"
		fi
	done
	;;
esac

case $SKIP_FISH in
true) sleep 0 ;;
*)
	v rsync -av --delete .config/fish/ "$XDG_CONFIG_HOME"/fish/
	;;
esac

# For Hyprland
case $SKIP_HYPRLAND in
true) sleep 0 ;;
*)

	v rsync -av --delete --exclude '/custom' --exclude '/hyprlock.conf' --exclude '/hypridle.conf' --exclude '/hyprland.conf' .config/hypr/ "$XDG_CONFIG_HOME"/hypr/
	v cp .config/hypr/hyprland.conf "$XDG_CONFIG_HOME/hypr/hyprland.conf"
	v cp .config/hypr/hypridle.conf "$XDG_CONFIG_HOME/hypr/hypridle.conf"
	v cp .config/hypr/hyprlock.conf "$XDG_CONFIG_HOME/hypr/hyprlock.conf"
	t="$XDG_CONFIG_HOME/hypr/custom"
	if [ -d $t ]; then
		echo -e "\e[34m[$0]: \"$t\" already exists, will not do anything.\e[0m"
	else
		echo -e "\e[33m[$0]: \"$t\" does not exist yet.\e[0m"
		v rsync -av --delete .config/hypr/custom/ $t/
	fi
	;;
esac

# some foldes (eg. .local/bin) should be processed separately to avoid `--delete' for rsync,
# since the files here come from different places, not only about one program.
# v rsync -av ".local/bin/" "$XDG_BIN_HOME" # No longer needed since scripts are no longer in ~/.local/bin

# Prevent hyprland from not fully loaded
sleep 1
try hyprctl reload

existed_zsh_conf=n
grep -q 'source ${XDG_CONFIG_HOME:-~/.config}/zshrc.d/dots-hyprland.zsh' ~/.zshrc && existed_zsh_conf=y

warn_files=()
warn_files_tests=()
warn_files_tests+=(/usr/local/lib/{GUtils-1.0.typelib,Gvc-1.0.typelib,libgutils.so,libgvc.so})
warn_files_tests+=(/usr/local/share/fonts/TTF/Rubik{,-Italic}'[wght]'.ttf)
warn_files_tests+=(/usr/local/share/licenses/ttf-rubik)
warn_files_tests+=(/usr/local/share/fonts/TTF/Gabarito-{Black,Bold,ExtraBold,Medium,Regular,SemiBold}.ttf)
warn_files_tests+=(/usr/local/share/licenses/ttf-gabarito)
warn_files_tests+=(/usr/local/share/icons/OneUI{,-dark,-light})
warn_files_tests+=(/usr/local/share/icons/Bibata-Modern-Classic)
warn_files_tests+=(/usr/local/bin/{LaTeX,res})
for i in ${warn_files_tests[@]}; do
	echo $i
	test -f $i && warn_files+=($i)
	test -d $i && warn_files+=($i)
done
