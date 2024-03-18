#!/usr/bin/env bash

term_alpha=100 # Set this to < 100 make all your terminals transparent
if [ ! -d "$HOME"/.cache/ags/user/generated ]; then
	mkdir -p "$HOME"/.cache/ags/user/generated
fi
cd "$HOME/.config/ags" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

# wallpath=$(swww query | awk -F 'image: ' '{print $2}')
# wallpath_png="$HOME"'/.cache/ags/user/generated/hypr/lockscreen.png'
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
	if [ ! -f "$HOME"/.cache/ags/user/colormode.txt ]; then
		echo "" >"$HOME"/.cache/ags/user/colormode.txt
	else
		lightdark=$(cat "$HOME"/.cache/ags/user/colormode.txt) # either "" or "-l"
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
	mkdir -p "$HOME"/.cache/ags/user/generated/fuzzel
	cp "scripts/templates/fuzzel/fuzzel.ini" "$HOME"/.cache/ags/user/generated/fuzzel/fuzzel.ini
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/fuzzel/fuzzel.ini
	done

	cp "$HOME"/.cache/ags/user/generated/fuzzel/fuzzel.ini "$HOME"/.config/fuzzel/fuzzel.ini
}

apply_term() {
	# Check if terminal escape sequence template exists
	if [ ! -f "scripts/templates/terminal/sequences.txt" ]; then
		echo "Template file not found for Terminal. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$HOME"/.cache/ags/user/generated/terminal
	cp "scripts/templates/terminal/sequences.txt" "$HOME"/.cache/ags/user/generated/terminal/sequences.txt
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/terminal/sequences.txt
	done

	sed -i "s/\$alpha/$term_alpha/g" "$HOME/.cache/ags/user/generated/terminal/sequences.txt"

	for file in /dev/pts/*; do
		if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
			cat "$HOME"/.cache/ags/user/generated/terminal/sequences.txt >"$file"
		fi
	done
}

apply_hyprland() {
	# Check if scripts/templates/hypr/hyprland/colors.conf exists
	if [ ! -f "scripts/templates/hypr/hyprland/colors.conf" ]; then
		echo "Template file not found for Hyprland colors. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$HOME"/.cache/ags/user/generated/hypr/hyprland
	cp "scripts/templates/hypr/hyprland/colors.conf" "$HOME"/.cache/ags/user/generated/hypr/hyprland/colors.conf
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprland/colors.conf
	done

	cp "$HOME"/.cache/ags/user/generated/hypr/hyprland/colors.conf "$HOME"/.config/hypr/hyprland/colors.conf
}

apply_hyprlock() {
	# Check if scripts/templates/hypr/hyprlock.conf exists
	if [ ! -f "scripts/templates/hypr/hyprlock.conf" ]; then
		echo "Template file not found for hyprlock. Skipping that."
		return
	fi
	# Copy template
	mkdir -p "$HOME"/.cache/ags/user/generated/hypr/
	cp "scripts/templates/hypr/hyprlock.conf" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
	# Apply colors
	# sed -i "s/{{ SWWW_WALL }}/${wallpath_png}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf
	done

	cp "$HOME"/.cache/ags/user/generated/hypr/hyprlock.conf "$HOME"/.config/hypr/hyprlock.conf
}

apply_gtk() { # Using gradience-cli
	lightdark=$(get_light_dark)

	# Copy template
	mkdir -p "$HOME"/.cache/ags/user/generated/gradience
	cp "scripts/templates/gradience/preset.json" "$HOME"/.cache/ags/user/generated/gradience/preset.json

	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$HOME"/.cache/ags/user/generated/gradience/preset.json
	done

	mkdir -p "$HOME/.config/presets" # create gradience presets folder
	gradience-cli apply -p "$HOME"/.cache/ags/user/generated/gradience/preset.json --gtk both

	# Set light/dark preference
	# And set GTK theme manually as Gradience defaults to light adw-gtk3
	# (which is unreadable when broken when you use dark mode)
	if [ "$lightdark" = "-l" ]; then
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

	mkdir -p "$HOME"/.cache/ags/user/generated/qt5ct
	mkdir -p "$HOME"/.config/qt5ct/colors

	# Copy template
	cp "scripts/templates/qt5ct/Colours.conf" "$HOME"/.cache/ags/user/generated/qt5ct/Colours.conf
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME"/.cache/ags/user/generated/qt5ct/Colours.conf
	done

	mv "$HOME"/.cache/ags/user/generated/qt5ct/Colours.conf "$HOME"/.config/qt5ct/colors/ags.conf
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
}

apply_nvchad() {
	# Check if scripts/templates/hypr/colors.conf exists
	if [ ! -f "scripts/templates/nvchad/ags.lua" ]; then
		echo "Template file not found for Hyprland colors. Skipping that."
		return
	fi
	# Copy template
	cp "scripts/templates/nvchad/ags.lua" "$HOME/.config/nvim/lua/custom/themes/ags_new.lua"
	# Apply colors
	for i in "${!colorlist[@]}"; do
		sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$HOME/.config/nvim/lua/custom/themes/ags_new.lua"
	done

	lightdark=$(get_light_dark)
	if [ "$lightdark" = "-l" ]; then
		sed -i "s/{{ \$colourtheme }}/light/g" "$HOME/.config/nvim/lua/custom/themes/ags_new.lua"
	else
		sed -i "s/{{ \$colourtheme }}/dark/g" "$HOME/.config/nvim/lua/custom/themes/ags_new.lua"
	fi

	mv "$HOME/.config/nvim/lua/custom/themes/ags_new.lua" "$HOME/.config/nvim/lua/custom/themes/ags.lua"
}

apply_ags() {
	sass "$HOME"/.config/ags/scss/main.scss "$HOME"/.cache/ags/user/generated/style.css
	ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'
	ags run-js "App.resetCss(); App.applyCss('${HOME}/.cache/ags/user/generated/style.css');"
}

apply_code() {
	lightdark=$(get_light_dark)
	echo light
	if [ "$lightdark" = "-l" ]; then
		sed -i 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "Default Light+"/g' ~/.config/Code/User/settings.json
	else
		sed -i 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "Default Dark+"/g' ~/.config/Code/User/settings.json
	fi

}

apply_darkman() {
	lightdark=$(get_light_dark)

	if [ "$lightdark" = "-l" ]; then
		darkman set light
	else
		darkman set dark
	fi
}

if [[ "$1" = "--bad-apple" ]]; then
	lightdark=$(get_light_dark)
	cp scripts/color_generation/specials/_material_badapple"${lightdark}".scss scss/_material.scss
	colornames=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f1)
	colorstrings=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
	IFS=$'\n'
	colorlist=($colornames)     # Array of color names
	colorvalues=($colorstrings) # Array of color values
else
	colornames=$(cat scss/_material.scss | cut -d: -f1)
	colorstrings=$(cat scss/_material.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
	IFS=$'\n'
	colorlist=($colornames)     # Array of color names
	colorvalues=($colorstrings) # Array of color values
fi

apply_ags &
apply_hyprland &
apply_hyprlock &
apply_gtk &
apply_fuzzel &
apply_term &
apply_kitty &
# apply_nvchad &
apply_darkman &
apply_code &
