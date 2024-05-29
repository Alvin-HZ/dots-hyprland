#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"
CACHE_DIR="$XDG_CACHE_HOME/ags"
STATE_DIR="$XDG_STATE_HOME/ags"

term_alpha=100 #Set this to < 100 make all your terminals transparent
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$CACHE_DIR"/user/generated ]; then
	mkdir -p "$CACHE_DIR"/user/generated
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

# wallpath=$(swww query | head -1 | awk -F 'image: ' '{print $2}')
# wallpath_png="$CACHE_DIR/user/generated/hypr/lockscreen.png"
# convert "$wallpath" "$wallpath_png"
# wallpath_png=$(echo "$wallpath_png" | sed 's/\//\\\//g')
# wallpath_png=$(sed 's/\//\\\\\//g' <<< "$wallpath_png")

transparentize() {
	local hex="$1"
	local alpha="$2"
	local red green blue

	red=$((16#${hex:1:2}))
	green=$((16#${hex:3:2}))
	blue=$((16#${hex:5:2}))

	printf 'rgba(%d, %d, %d, %.2f)\n' "$red" "$green" "$blue" "$alpha"
}

get_light_dark() {
	lightdark=""
	if [ ! -f "$CACHE_DIR"/user/colormode.txt ]; then
		echo "" >"$CACHE_DIR"/user/colormode.txt
	else
		lightdark=$(sed -n '1p' "$HOME/.cache/ags/user/colormode.txt")
	fi
	echo "$lightdark"
}

apply_fuzzel() {
	# Check if scripts/templates/fuzzel/fuzzel.ini exists
	if [ ! -f "scripts/templates/fuzzel/fuzzel.ini" ]; then
		echo "Template file not found for Fuzzel. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$CACHE_DIR"/user/generated/fuzzel
	cp "scripts/templates/fuzzel/fuzzel.ini" "$CACHE_DIR"/user/generated/fuzzel/fuzzel.ini
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/fuzzel/fuzzel.ini
	done

	cp "$CACHE_DIR"/user/generated/fuzzel/fuzzel.ini "$XDG_CONFIG_HOME"/fuzzel/fuzzel.ini
}

apply_term() {
	# Check if terminal escape sequence template exists
	if [ ! -f "scripts/templates/terminal/sequences.txt" ]; then
		echo "Template file not found for Terminal. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$CACHE_DIR"/user/generated/terminal
	cp "scripts/templates/terminal/sequences.txt" "$CACHE_DIR"/user/generated/terminal/sequences.txt
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/terminal/sequences.txt
	done

	sed -i "s/\$alpha/$term_alpha/g" "$CACHE_DIR/user/generated/terminal/sequences.txt"

	for file in /dev/pts/*; do
		if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
			cat "$CACHE_DIR"/user/generated/terminal/sequences.txt >"$file"
		fi
	done
}

apply_kitty() {
	# Check if scripts/templates/hypr/colors.conf exists
	if [ ! -f "scripts/templates/kitty/theme.conf" ]; then
		echo "Template file not found for Hyprland colors. Skipping that."
		return
	fi
	# Copy template
	mkdir "$HOME/.config/kitty/themes/"
	cp "scripts/templates/kitty/theme.conf" "$HOME/.config/kitty/themes/theme_new.conf"
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME/.config/kitty/themes/theme_new.conf"
	done

	mv "$HOME/.config/kitty/themes/theme_new.conf" "$HOME/.config/kitty/themes/theme.conf"
	kitten themes --reload-in=all ags
}

apply_hyprland() {
	# Check if scripts/templates/hypr/hyprland/colors.conf exists
	if [ ! -f "scripts/templates/hypr/hyprland/colors.conf" ]; then
		echo "Template file not found for Hyprland colors. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$CACHE_DIR"/user/generated/hypr/hyprland
	cp "scripts/templates/hypr/hyprland/colors.conf" "$CACHE_DIR"/user/generated/hypr/hyprland/colors.conf
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/hypr/hyprland/colors.conf
	done

	cp "$CACHE_DIR"/user/generated/hypr/hyprland/colors.conf "$XDG_CONFIG_HOME"/hypr/hyprland/colors.conf
}

apply_hyprlock() {
	# Check if scripts/templates/hypr/hyprlock.conf exists
	if [ ! -f "scripts/templates/hypr/hyprlock.conf" ]; then
		echo "Template file not found for hyprlock. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$CACHE_DIR"/user/generated/hypr/
	cp "scripts/templates/hypr/hyprlock.conf" "$CACHE_DIR"/user/generated/hypr/hyprlock.conf
	# Apply colors
	# sed -i "s/{{ SWWW_WALL }}/${wallpath_png}/g" "$CACHE_DIR"/user/generated/hypr/hyprlock.conf
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/hypr/hyprlock.conf
	done

	cp "$CACHE_DIR"/user/generated/hypr/hyprlock.conf "$XDG_CONFIG_HOME"/hypr/hyprlock.conf
}

apply_gtk() { # Using gradience-cli
	lightdark=$(get_light_dark)

	# Copy template
	mkdir -p "$CACHE_DIR"/user/generated/gradience
	cp "scripts/templates/gradience/preset.json" "$CACHE_DIR"/user/generated/gradience/preset.json

	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$CACHE_DIR"/user/generated/gradience/preset.json
	done

	mkdir -p "$XDG_CONFIG_HOME/presets" # create gradience presets folder
	gradience-cli apply -p "$CACHE_DIR"/user/generated/gradience/preset.json --gtk both

	# Set light/dark preference
	# And set GTK theme manually as Gradience defaults to light adw-gtk3
	# (which is unreadable when broken when you use dark mode)
	if [ "$lightdark" = "light" ]; then
		gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
		gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
	else
		gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
		gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	fi
}

apply_qt() {
	# Check if scripts/templates/hypr/colors.conf exists
	if [ ! -f "scripts/templates/qt5ct/Colours.conf" ]; then
		echo "Template file not found for Hyprland colors. Skipping that."
		return
	fi

	mkdir -p "$CACHE_DIR"/user/generated/qt5ct
	mkdir -p "$XDG_CONFIG_HOME"/.config/qt5ct/colors

	# Copy template
	cp "scripts/templates/qt5ct/Colours.conf" "$CACHE_DIR"/user/generated/qt5ct/Colours.conf
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/qt5ct/Colours.conf
	done

	mv "$CACHE_DIR"/user/generated/qt5ct/Colours.conf "$XDG_CONFIG_HOME"/.config/qt5ct/colors/ags.conf
}

apply_ags() {
	sass -I "$STATE_DIR/scss" -I "$CONFIG_DIR/scss/fallback" "$CONFIG_DIR"/scss/main.scss "$CACHE_DIR"/user/generated/style.css
	ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'
	ags run-js "App.resetCss(); App.applyCss('${CACHE_DIR}/user/generated/style.css');"
}

apply_code() {
	lightdark=$(get_light_dark)
	echo light,
	if [ "$lightdark" = "light" ]; then
		sed -i 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "Default Light Modern"/g' ~/.config/Code/User/settings.json
	else
		sed -i 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "Default Dark Modern"/g' ~/.config/Code/User/settings.json
	fi

}

apply_vesktop() {
	# Check if scripts/templates/vesktop/discord.css exists
	if [ ! -f "scripts/templates/vesktop/discord.css" ]; then
		echo "Template file not found for Hyprland colors. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$CACHE_DIR"/user/generated/vesktop
	cp "scripts/templates/vesktop/discord.css" "$CACHE_DIR"/user/generated/vesktop/discord.css
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{${colorlist[$i]}}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/vesktop/discord.css
	done

	cp "$CACHE_DIR"/user/generated/vesktop/discord.css "$XDG_CONFIG_HOME"/vesktop/themes/discord.css
}

apply_darkman() {
	lightdark=$(get_light_dark)

	if [ "$lightdark" = "light" ]; then
		darkman set light
	else
		darkman set dark
	fi
}

if [[ "$1" = "--bad-apple" ]]; then
	lightdark=$(get_light_dark)
	cp scripts/color_generation/specials/_material_badapple"${lightdark}".scss $STATE_DIR/scss/_material.scss
	colornames=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f1)
	colorstrings=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
	IFS=$'\n'
	colorlist=($colornames)     # Array of color names
	colorvalues=($colorstrings) # Array of color values
else
	colornames=$(cat $STATE_DIR/scss/_material.scss | cut -d: -f1)
	colorstrings=$(cat $STATE_DIR/scss/_material.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
	IFS=$'\n'
	colorlist=($colornames)     # Array of color names
	colorvalues=($colorstrings) # Array of color values
fi
apply_ags &
apply_hyprland &
apply_hyprlock &
apply_gtk &
apply_fuzzel &
#apply_term &
apply_kitty &
apply_qt &
# apply_nvchad &
apply_darkman &
apply_code &
apply_vesktop &

