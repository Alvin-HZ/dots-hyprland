import PopupWindow from '../.widgethacks/popupwindow.js';
import SidebarLeft from "./sideleft.js";

export default () => PopupWindow({
    keymode: 'exclusive',
    anchor: ['left', 'top', 'bottom'],
    name: 'sideleft',
    showClassName: 'sideleft-show',
    hideClassName: 'sideleft-hide',
    child: SidebarLeft(),
});
