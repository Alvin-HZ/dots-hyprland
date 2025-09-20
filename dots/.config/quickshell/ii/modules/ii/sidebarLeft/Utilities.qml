import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

/**
 * Translator widget with the `trans` commandline tool.
 */
Item {
    id: root
    ColumnLayout {
        anchors.fill: parent
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.implicitHeight

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                spacing: 15

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Special Workspace"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "togglespecialworkspace"]);
                    }
                }

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Special Workspace M"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "togglespecialworkspace", "music"]);
                    }
                }

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Special Workspace D"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "togglespecialworkspace", "discord"]);
                    }
                }

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Special Workspace Z"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "togglespecialworkspace", "z"]);
                    }
                }

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Special Workspace O"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "togglespecialworkspace", "o"]);
                    }
                }

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Audio"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "exec", "pavucontrol-qt"]);
                    }
                }

                RippleButtonWithIcon {
                    implicitHeight: 75
                    Layout.fillWidth: true

                    materialIcon: "Play_Circle"
                    materialIconFill: false
                    mainText: "Bluetooth"
                    onClicked: {
                        Quickshell.execDetached(["hyprctl", "dispatch", "exec", `${Config.options.apps.bluetooth}`]);
                    }
                }
            }    
        }

    }

}
