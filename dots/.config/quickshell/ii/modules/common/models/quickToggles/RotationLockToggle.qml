import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: "Rotation Lock"

    toggled: false
    icon: "mobile_rotate_lock"
    
    mainAction: () => {
        // fetchActiveState.exec();
        toggleState.running = true;
    }

    Process {
        id: fetchInitialState
        running: true
        command: ["pidof","iio-hyprland"]
        
        onExited: function(exitCode, exitStatus) {  
          root.toggled = exitCode != 0
        }
    }

    Process {
        id: toggleState
        running: false
        command: ["pidof","iio-hyprland"]
        
        onExited: function(exitCode, exitStatus) {  
          root.toggled = exitCode == 0
          if (root.toggled) {
              Quickshell.execDetached(["pkill", "iio-hyprland"])
          } else {
              Quickshell.execDetached(["iio-hyprland"])
          }
        }
    }

    tooltipText: "Rotation Lock"
}
