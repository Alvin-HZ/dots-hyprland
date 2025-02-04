#!/usr/bin/env bash
cd "$(dirname "$0")"
export base="$(pwd)"
source ./scriptdata/environment-variables
source ./scriptdata/functions
source ./scriptdata/installers
source ./scriptdata/options

#####################################################################################
if ! command -v pacman >/dev/null 2>&1; then
	printf "\e[31m[$0]: pacman not found, it seems that the system is not ArchLinux or Arch-based distros. Aborting...\e[0m\n"
	exit 1
fi
prevent_sudo_or_root

set -e
#####################################################################################
printf "\e[36m[$0]: 1. Get packages and setup user groups/services\n\e[0m"

# Issue #363
# case $SKIP_SYSUPDATE in
#   true) sleep 0;;
#   *) v sudo pacman -Syu;;
# esac

remove_bashcomments_emptylines ${DEPLISTFILE} ./cache/dependencies_stripped.conf
readarray -t pkglist <./cache/dependencies_stripped.conf

# Use yay. Because paru do not support cleanbuild.
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

# Convert old dependencies to non explicit dependencies so that they can be orphaned if not in meta packages
set-explicit-to-implicit() {
	remove_bashcomments_emptylines ./scriptdata/previous_dependencies.conf ./cache/old_deps_stripped.conf
	readarray -t old_deps_list <./cache/old_deps_stripped.conf
	pacman -Qeq >./cache/pacman_explicit_packages
	readarray -t explicitly_installed <./cache/pacman_explicit_packages

	echo "Attempting to set previously explicitly installed deps as implicit..."
	for i in "${explicitly_installed[@]}"; do for j in "${old_deps_list[@]}"; do
		[ "$i" = "$j" ] && yay -D --asdeps "$i"
	done; done

	return 0
}

$ask && echo "Attempt to set previously explicitly installed deps as implicit? "
$ask && showfun set-explicit-to-implicit
v set-explicit-to-implicit

# https://github.com/end-4/dots-hyprland/issues/581
# yay -Bi is kinda hit or miss, instead cd into the relevant directory and manually source and install deps
install-local-pkgbuild() {
	local location=$1
	local installflags=$2

	x pushd $location

	source ./PKGBUILD
	x yay -S $installflags --asdeps "${depends[@]}"
	x makepkg -si --noconfirm

	x popd
}

# Install core dependencies from the meta-packages
metapkgs=(./arch-packages/illogical-impulse-{audio,backlight,basic,fonts-themes,gnome,gtk,portal,python,screencapture,widgets})
metapkgs+=(./arch-packages/illogical-impulse-ags)
metapkgs+=(./arch-packages/illogical-impulse-microtex-git)
metapkgs+=(./arch-packages/illogical-impulse-oneui4-icons-git)
[[ -f /usr/share/icons/Bibata-Modern-Classic/index.theme ]] ||
	metapkgs+=(./arch-packages/illogical-impulse-bibata-modern-classic-bin)
try sudo pacman -R illogical-impulse-microtex

for i in "${metapkgs[@]}"; do
	metainstallflags="--needed"
	$ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
	v install-local-pkgbuild "$i" "$metainstallflags"
done

# https://github.com/end-4/dots-hyprland/issues/428#issuecomment-2081690658
# https://github.com/end-4/dots-hyprland/issues/428#issuecomment-2081701482
# https://github.com/end-4/dots-hyprland/issues/428#issuecomment-2081707099
case $SKIP_PYMYC_AUR in
true) sleep 0 ;;
*)
	pymycinstallflags=""
	$ask && showfun install-local-pkgbuild || pymycinstallflags="$pymycinstallflags --noconfirm"
	v install-local-pkgbuild "./arch-packages/illogical-impulse-pymyc-aur" "$pymycinstallflags"
	;;
esac

# Why need cleanbuild? see https://github.com/end-4/dots-hyprland/issues/389#issuecomment-2040671585
# Why install deps by running a seperate command? see pinned comment of https://aur.archlinux.org/packages/hyprland-git
ask=true
case $SKIP_HYPR_AUR in
true) sleep 0 ;;
*)
	hyprland_installflags="-S"
	$ask || hyprland_installflags="$hyprland_installflags --noconfirm"
	v yay $hyprland_installflags --asdeps hyprutils-git hyprlang-git hyprcursor-git hyprwayland-scanner-git
	v yay $hyprland_installflags --answerclean=a hyprland-git
	;;
esac
