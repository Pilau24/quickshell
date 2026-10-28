pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../../core"

// qmllint disable unqualified
Item {
  id: root

  required property var screen
  required property var config
  required property int barHeight
  required property var slot

  readonly property int dotSize: 8
  readonly property int pillWidth: 20
  readonly property int reservedCount: 10

  property var workspaceIds: []
  property int activeId: -1
  property var urgentIds: []

  implicitWidth: row.width
  implicitHeight: dotSize

  function refreshWorkspaces() {
    const open = Hyprland.workspaces.values.filter(ws => ws.id > 0)
    const onScreen = open.filter(ws => ws.monitor?.name === root.screen.name)
    const ids = []

    if (root.screen.name === root.config.resolvedPrimaryMonitor) {
      const elsewhere = new Set(open.filter(ws => ws.monitor && ws.monitor.name !== root.screen.name).map(ws => ws.id))
      for (let id = 1; id <= root.reservedCount; id++) {
        if (!elsewhere.has(id)) ids.push(id)
      }
      for (const ws of onScreen) {
        if (ws.id > root.reservedCount) ids.push(ws.id)
      }
    } else {
      for (const ws of onScreen) ids.push(ws.id)
      const monitorActive = Hyprland.monitorFor(root.screen)?.activeWorkspace
      if (ids.length === 0 && monitorActive && monitorActive.id > 0) ids.push(monitorActive.id)
    }

    ids.sort((a, b) => a - b)
    if (ids.join() !== root.workspaceIds.join()) root.workspaceIds = ids

    const active = Hyprland.monitorFor(root.screen)?.activeWorkspace
    root.activeId = active ? active.id : -1
    root.urgentIds = open.filter(ws => ws.urgent).map(ws => ws.id)
  }

  Component.onCompleted: refreshWorkspaces()

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      root.refreshWorkspaces()
    }
  }

  Row {
    id: row
    spacing: 6

    Repeater {
      model: root.workspaceIds

      delegate: Rectangle {
        id: dot
        required property var modelData

        readonly property bool focused: modelData === root.activeId
        readonly property bool urgent: root.urgentIds.includes(modelData)

        width: focused ? root.pillWidth : root.dotSize
        height: root.dotSize
        radius: height / 2
        color: focused ? root.config.accent : urgent ? root.config.barText : root.config.muted

        Behavior on width {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${dot.modelData} })`)
        }
      }
    }
  }
}
