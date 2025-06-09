#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options
# ask=false

XDG_CONFIG_HOME=~/.config/
XDG_BIN_HOME=~/.local/bin/

# MISC (For .config/* but not AGS, not Fish, not Hyprland)

# Issue #363
# case $SKIP_SYSUPDATE in
#   true) sleep 0;;
#   *) v sudo pacman -Syu;;
# esac

remove_bashcomments_emptylines ${DEPLISTFILE} ./cache/dependencies_stripped.conf
readarray -t pkglist <./cache/dependencies_stripped.conf

# Use yay. Because paru does not support cleanbuild.
# Also see https://wiki.hyprland.org/FAQ/#how-do-i-update
if ! command -v yay >/dev/null 2>&1; then
	echo -e "\e[33m[$0]: \"yay\" not found.\e[0m"
	showfun install-yay
	v install-yay
fi

# Install extra packages from dependencies.conf as declared by the user
if ((${#pkglist[@]} != 0)); then
	if $ask; then
		# execute per element of the array $pkglist
		for i in "${pkglist[@]}"; do v yay -S --needed $i; done
	else
		# execute for all elements of the array $pkglist in one line
		v yay -S --needed --noconfirm ${pkglist[*]}
	fi
fi

showfun handle-deprecated-dependencies
v handle-deprecated-dependencies

# https://github.com/end-4/dots-hyprland/issues/581
# yay -Bi is kinda hit or miss, instead cd into the relevant directory and manually source and install deps
install-local-pkgbuild() {
	local location=$1
	local installflags=$2

	x pushd $location

	source ./PKGBUILD
	x yay -S $installflags --asdeps "${depends[@]}"
	x makepkg -Asi --noconfirm

	x popd
}

# Install core dependencies from the meta-packages
metapkgs=(./arch-packages/illogical-impulse-{audio,python,backlight,basic,fonts-themes,gnome,gtk,portal,screencapture,widgets})
metapkgs+=(./arch-packages/illogical-impulse-agsv1-git)
metapkgs+=(./arch-packages/illogical-impulse-hyprland)
metapkgs+=(./arch-packages/illogical-impulse-microtex-git)
metapkgs+=(./arch-packages/illogical-impulse-oneui4-icons-git)
[[ -f /usr/share/icons/Bibata-Modern-Classic/index.theme ]] ||
	metapkgs+=(./arch-packages/illogical-impulse-bibata-modern-classic-bin)

for i in "${metapkgs[@]}"; do
	metainstallflags="--needed"
	$ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
	v install-local-pkgbuild "$i" "$metainstallflags"
done

# These python packages are installed using uv, not pacman.
showfun install-python-packages
v install-python-packages

## Optional dependencies
# if pacman -Qs ^plasma-browser-integration$ ;then SKIP_PLASMAINTG=true;fi
# case $SKIP_PLASMAINTG in
#   true) sleep 0;;
#   *)
#     if $ask;then
#       echo -e "\e[33m[$0]: NOTE: The size of \"plasma-browser-integration\" is about 250 MiB.\e[0m"
#       echo -e "\e[33mIt is needed if you want playtime of media in Firefox to be shown on the music controls widget.\e[0m"
#       echo -e "\e[33mInstall it? [y/N]\e[0m"
#       read -p "====> " p
#     else
#       p=y
#     fi
#     case $p in
#       y) x sudo pacman -S --needed --noconfirm plasma-browser-integration ;;
#       *) echo "Ok, won't install"
#     esac
#     ;;
# esac

v sudo usermod -aG video,i2c,input "$(whoami)"
v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
v systemctl --user enable ydotool --now
v sudo systemctl enable bluetooth --now
# v gsettings set org.gnome.desktop.interface font-name 'Rubik 11'
# v gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
