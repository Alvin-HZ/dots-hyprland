#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options
printf "\e[36m[$0]: 3. Copying\e[97m\n"
ask=false

XDG_CONFIG_HOME=~/.config/
XDG_BIN_HOME=~/.local/bin/

# MISC (For .config/* but not AGS, not Fish, not Hyprland)
case $SKIP_MISCCONF in
true) sleep 0 ;;
*)
	for i in $(find .config/ -mindepth 1 -maxdepth 1 ! -name 'ags' ! -name 'fish' ! -name 'hypr' -exec basename {} \;); do
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

# For AGS
case $SKIP_AGS in
true) sleep 0 ;;
*)
	v rsync -av --delete --exclude '/user_options.js' .config/ags/ "$XDG_CONFIG_HOME"/ags/
	t="$XDG_CONFIG_HOME/ags/user_options.js"
	if [ -f $t ]; then
		echo -e "\e[34m[$0]: \"$t\" already exists.\e[0m"
		# v cp -f .config/ags/user_options.js $t.new
		existed_ags_opt=y
	else
		echo -e "\e[33m[$0]: \"$t\" does not exist yet.\e[0m"
		v cp .config/ags/user_options.js $t
		existed_ags_opt=n
	fi
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
	;;
esac

# some foldes (eg. .local/bin) should be processed separately to avoid `--delete' for rsync,
# since the files here come from different places, not only about one program.
v rsync -av ".local/bin/" "$XDG_BIN_HOME"

# Prevent hyprland from not fully loaded
sleep 1
try hyprctl reload

existed_zsh_conf=n
grep -q 'source ${XDG_CONFIG_HOME:-~/.config}/zshrc.d/dots-hyprland.zsh' ~/.zshrc && existed_zsh_conf=y

warn_files=()
warn_files_tests=()
warn_files_tests+=(/usr/local/bin/ags)
warn_files_tests+=(/usr/local/etc/pam.d/ags)
warn_files_tests+=(/usr/local/lib/{GUtils-1.0.typelib,Gvc-1.0.typelib,libgutils.so,libgvc.so})
warn_files_tests+=(/usr/local/share/com.github.Aylur.ags)
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
