import Quickshell
import Quickshell.Wayland
import QtQuick

// qmllint disable uncreatable-type
PanelWindow {
  id: root

  required property var config
  default property alias widgets: widgetArea.data

  anchors { top: true; left: true; right: true }
  implicitHeight: config.barHeight
  color: config.barBackground
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  // Declared before the widget area so the widgets stay clickable.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    onPressed: mouse => {
      if (mouse.modifiers & Qt.ControlModifier) Quickshell.reload(false)
    }
  }

  Item {
    id: widgetArea
    anchors.fill: parent
  }

  BarSlot { id: leftBarSlot; align: "left" }
  BarSlot { id: centerBarSlot; align: "center" }
  BarSlot { id: rightBarSlot; align: "right" }

  DismissLayer {
    config: root.config
    targetScreen: root.screen
    slots: root.slots
  }

  readonly property alias leftSlot: leftBarSlot
  readonly property alias centerSlot: centerBarSlot
  readonly property alias rightSlot: rightBarSlot
  readonly property var slots: [leftBarSlot, centerBarSlot, rightBarSlot]
}
