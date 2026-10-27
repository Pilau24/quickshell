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
  property int maxContentHeight: 0

  function toggle() {
    slot.active = open ? null : root
  }

  visible: open
  screen: root.targetScreen
  anchors { top: true; left: true }


    // qmllint disable missing-property
  margins {
    top: root.config.panelMargin
    left: root.slot.align === "left" ? root.config.panelMargin : root.slot.align === "right" ? root.targetScreen.width - implicitWidth - root.config.panelMargin : (root.targetScreen.width - implicitWidth) / 2
  }
  implicitWidth: loader.implicitWidth + root.config.panelPadding
  implicitHeight: root.maxContentHeight > 0 ? root.maxContentHeight : loader.implicitHeight + root.config.panelPadding
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay
  mask: Region { item: panelRect }

  Rectangle {
    id: panelRect
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: loader.implicitHeight + root.config.panelPadding
    color: root.config.barBackground
    radius: root.config.roundingPx * root.cornerScale

    Loader {
      id: loader
      anchors.top: parent.top
      anchors.topMargin: root.config.panelPadding / 2
      anchors.horizontalCenter: parent.horizontalCenter
      sourceComponent: root.content
    }
  }
}
