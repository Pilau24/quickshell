pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick

Rectangle {
  id: root

  required property SystemTrayItem trayItem
  required property var config
  required property int barHeight

  readonly property int iconSize: barHeight - 8

  function focusApp() {
    const id = root.trayItem.id.toLowerCase()
    const match = Hyprland.toplevels.values.find(t => {
      const cls = (t.lastIpcObject?.class ?? "").toLowerCase()
      return cls !== "" && id.includes(cls)
    })
    if (match) Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${match.address}" })`)
    else launchApp()
  }

  function launchApp() {
    const entry = DesktopEntries.byId(root.trayItem.id)
    if (entry) entry.execute()
    else Quickshell.execDetached([root.trayItem.id])
  }

  implicitWidth: iconSize + 16
  implicitHeight: barHeight
  color: config.barBackground
  radius: config.roundingPx

  Image {
    anchors.centerIn: parent
    width: root.iconSize
    height: root.iconSize
    source: root.trayItem.icon
    sourceSize: Qt.size(root.iconSize, root.iconSize)
    fillMode: Image.PreserveAspectFit
    smooth: true
  }

  QsMenuAnchor {
    id: menuAnchor

    menu: root.trayItem.menu
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
      if (mouse.button === Qt.MiddleButton) {
        root.focusApp()
      } else if (mouse.button === Qt.RightButton || root.trayItem.onlyMenu) {
        if (root.trayItem.hasMenu) menuAnchor.open()
      } else {
        root.trayItem.activate()
      }
    }
  }
}
