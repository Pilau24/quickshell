//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "components/core"
import "components/widgets/notifcenter"
import "components/widgets/workspaces"
import "components/widgets/tray"

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

          WorkspacesWidget {
            screen: bar.screen
            config: configLoader
            barHeight: configLoader.barHeight
            slot: bar.leftSlot
          }
        }

        Row {
          anchors.right: parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          TrayWidget {
            screen: bar.screen
            config: configLoader
            barHeight: configLoader.barHeight
            slot: bar.rightSlot
          }

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
