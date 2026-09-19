import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property string dictationState: "idle"
    property string statusMessage: ""

    function setState(nextState, message) {
        root.dictationState = nextState;
        root.statusMessage = message || "";
        hideTimer.stop();
        if (nextState === "error") {
            hideTimer.interval = 1800;
            hideTimer.start();
        }
    }

    Timer {
        id: hideTimer
        onTriggered: root.setState("idle", "")
    }

    IpcHandler {
        target: "dictationOverlay"

        function listening(): void {
            root.setState("listening", "")
        }

        function transcribing(): void {
            root.setState("transcribing", "")
        }

        function success(): void {
            root.setState("idle", "")
        }

        function error(message: string): void {
            root.setState("error", message)
        }

        function idle(): void {
            root.setState("idle", "")
        }
    }

    PanelWindow {
        id: panel
        visible: root.dictationState !== "idle"
        color: "transparent"
        implicitWidth: 360
        implicitHeight: 144
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:dictation-overlay"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        mask: Region { item: null }

        Rectangle {
            id: shadow
            anchors.centerIn: capsule
            width: capsule.width + 6
            height: capsule.height + 8
            radius: height / 2
            color: "#50000000"
            opacity: panel.visible ? 1 : 0
        }

        Rectangle {
            id: capsule
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 96
            width: 64
            height: 34
            radius: height / 2
            color: "#151619"

            Row {
                id: bars
                anchors.centerIn: parent
                spacing: 3
                height: 24
                visible: root.dictationState !== "idle"

                Repeater {
                    model: 5

                    Rectangle {
                        required property int index
                        property real lowHeight: 5 + (index % 3) * 2
                        property real highHeight: 12 + ((index * 7) % 4) * 3
                        width: 3
                        height: lowHeight
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#f5f5f7"

                        SequentialAnimation on height {
                            running: root.dictationState !== "idle"
                            loops: Animation.Infinite
                            PauseAnimation { duration: index * 55 }
                            NumberAnimation {
                                to: highHeight
                                duration: 220 + index * 18
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: lowHeight
                                duration: 280 + index * 16
                                easing.type: Easing.InOutSine
                            }
                        }
                    }
                }
            }
        }
    }
}
