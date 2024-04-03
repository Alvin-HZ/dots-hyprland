import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { Closer } from "./windowcloser.js";
import { enableClickthrough } from "../.widgetutils/clickthrough.js";

export default () => Widget.Window({
    name: 'windowCloser',
    keymode: 'none',
    anchor: ['top', 'left', 'right'],
    exclusivity: 'ignore',
    layer: "top",
    visible: false,
    child: Closer(),
});
