const { Gtk } = imports.gi;
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { execAsync, exec } = Utils;
const { Box, Button, EventBox, Icon, Label, Scrollable } = Widget;
import SidebarModule from './module.js';
import { MaterialIcon } from '../../.commonwidgets/materialicon.js';
import { setupCursorHover } from '../../.widgetutils/cursorhover.js';

async function GetUpdateCount() {
    // execAsync(`notify-send 'Urgent notification' 'checking packages' -u critical -a 'Hyprland keybind'`)
    let aur= execAsync(["bash", "-c", "yay -Qua | wc -l"]);
    // execAsync(`notify-send 'Urgent notification' 'checking aur' -u critical -a 'Hyprland keybind'`)
    let ofc= execAsync(["bash", "-c", "checkupdates | wc -l"]);
    let fpk= execAsync(["bash", "-c", "flatpak remote-ls --updates | wc -l"]);
    // let fpk= execAsync(`flatpak remote-ls --updates`)
    
    // execAsync(`notify-send 'Urgent notification' 'checking aur' -u critical -a 'Hyprland keybind'`)
    aur = Number(await aur)
    ofc = Number(await ofc)
    fpk = Number(await fpk)
    // console.log(aur+ofc+fpk)
    return (aur+ofc+fpk);
}

async function UpdateLabel(self) {
    const updateCount = await GetUpdateCount();
    if (updateCount === 0) {
        self.label = `Packages are up to date`
        return
    }
    self.label = `Packages are not up to date (${updateCount})`
}

const ButtonLabel = Label({
    className: 'txt-small',
    hpack: 'start',
    hexpand: true,
    setup: (self) => self.poll(3000000, UpdateLabel),
});

const scriptStateIcon = MaterialIcon('not_started', 'norm');
export default () => SidebarModule({
    icon: MaterialIcon('code', 'norm'),
    name: 'Package Updater',
    child: Box({
        vertical: true,
        className: 'spacing-v-5',
        children: [
            Box({
                className: 'spacing-h-5 txt',
                children: [
                    ButtonLabel,
                    Button({
                        className: 'sidebar-module-scripts-button',
                        child: scriptStateIcon,
                        onClicked: () => {
                            App.closeWindow('sideleft');
                            execAsync('kitty --title systemupdate sh -c "yay -Syu; flatpak update "').catch(print)
                                .then(() => {
                                    UpdateLabel(ButtonLabel)
                                    scriptStateIcon.label = 'done';
                                })
                        },
                        setup: setupCursorHover,
                    }),
                ],
            })
        ],
    })
});