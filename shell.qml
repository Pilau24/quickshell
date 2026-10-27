pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "components/core"
import "components/widgets/notifcenter"

ShellRoot {
  Config { id: configLoader }

  Variants {
    model: Quickshell.screens

    Scope {
      id: monitor
      required property var modelData

      Bar {
        id: bar
        config: configLoader
        screen: monitor.modelData

        Row {
          anchors.left: parent.left
          anchors.leftMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8
        }

        Row {
          anchors.right: parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          ClockWidget {
            important: false
            slot: bar.rightSlot
            screen: bar.screen
            config: configLoader
            barHeight: configLoader.barHeight
          }
        }
      }
    }
  }
}
