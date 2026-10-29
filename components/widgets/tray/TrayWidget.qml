pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Item {
  id: root

  required property var screen
  required property var config
  required property int barHeight
  required property var slot

  visible: config.showTray && screen.name === config.resolvedPrimaryMonitor
  implicitWidth: row.implicitWidth
  implicitHeight: root.barHeight

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    Repeater {
      model: SystemTray.items

      TrayItem {
        required property SystemTrayItem modelData
        trayItem: modelData
        config: root.config
        barHeight: root.barHeight
      }
    }
  }
}
