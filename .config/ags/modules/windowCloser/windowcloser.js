import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';

const Names = ["overview", "sideleft", "sideright", "cheatsheet"]

const CloseWindows = () => {
    App.closeWindow("windowCloser")
    for (const name of Names) {
        App.closeWindow(name)
    }
}

const CheckIfOpen = () => {
    for (const name of Names) {
        if (App.getWindow(name).visible) {
            return true
        }
    }
    return false
}

const ClickToClose = ({ ...props }) => Widget.EventBox({
    ...props,
    onPrimaryClick: CloseWindows,
    onSecondaryClick: CloseWindows,
    onMiddleClick: CloseWindows,
    
    setup: (self) => self.hook(App, (self, name, visible) => { // Update on open
            if (Names.includes(name)) {
                if (visible) {
                    App.openWindow('windowCloser')
                } else {
                    if (!CheckIfOpen()) {
                        App.closeWindow('windowCloser')
                    }
                    // CheckIfOpen()
                }
            }
        }, 'window-toggled')
});

export const Closer = () => ClickToClose({
    child: Widget.Box({
        // className: "full-size",
        css: "min-height: 200rem; min-width:  200rem;"
    })
});