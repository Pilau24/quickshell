import Quickshell
import Quickshell.Wayland
import QtQuick

// qmllint disable uncreatable-type
PanelWindow {
  id: root

  required property var targetScreen
  required property var config
  required property int barHeight
  required property var slot
  readonly property bool open: slot.active === root
  property Component content
  property real cornerScale: 1

  function toggle() {
    slot.active = open ? null : root
  }

  visible: open
  screen: root.targetScreen
  anchors { top: true; left: true }


    // qmllint disable missing-property
  margins {
    top: root.config.panelGap
    left: root.slot.align === "left" ? root.config.panelPadding : root.slot.align === "right" ? root.targetScreen.width - implicitWidth - root.config.panelPadding : (root.targetScreen.width - implicitWidth) / 2
  }
  implicitWidth: loader.implicitWidth + 16
  implicitHeight: root.barHeight
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay

  Rectangle {
    anchors.fill: parent
    color: root.config.barBackground
    radius: root.config.roundingFactor * root.cornerScale

    Loader {
      id: loader
      anchors.centerIn: parent
      sourceComponent: root.content
    }
  }
}
