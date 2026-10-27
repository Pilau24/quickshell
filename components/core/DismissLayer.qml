import Quickshell
import Quickshell.Wayland
import QtQuick

// qmllint disable uncreatable-type
PanelWindow {
  id: root

  required property var config
  required property var targetScreen
  required property var slots

  readonly property bool anyOpen: slots.some(slot => slot.active !== null)

  function closeAll() {
    for (const slot of slots) slot.active = null
  }

  screen: root.targetScreen
  visible: anyOpen && !config.debug
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  onVisibleChanged: if (visible) keyHandler.forceActiveFocus()

  MouseArea {
    anchors.fill: parent
    onClicked: root.closeAll()
  }

  Item {
    id: keyHandler
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: root.closeAll()
  }
}
