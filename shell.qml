pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "components/core"
import "components/widgets"

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
          anchors.centerIn: parent
          spacing: 8

          ClockWidget {
            important: true
            slot: bar.centerSlot
            screen: bar.screen
            config: configLoader
            barHeight: configLoader.barHeight
          }
        }
      }
    }
  }
}
