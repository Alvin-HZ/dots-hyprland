import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Scrollable } = Widget;
import QuickScripts from './tools/quickscripts.js';
import PackageUpdater from './tools/updatepackages.js'
import ColorPicker from './tools/colorpicker.js';

export default Scrollable({
    hscroll: "never",
    vscroll: "automatic",
    child: Box({
        vertical: true,
        className: 'spacing-v-10',
        children: [
            PackageUpdater(),
            QuickScripts(),
            ColorPicker(),
        ]
    })
});
