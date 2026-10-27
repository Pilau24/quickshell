import QtQuick
import Quickshell.Io
import "../../ui"

Card {
  id: root

  property var notifications: []
  property bool expanded: false
  property bool panelOpen: false
  readonly property int collapsedCount: 3
  readonly property real listHeight: root.notifications.length === 0 ? emptyText.implicitHeight + 12 : notifList.itemsHeight
  readonly property real contentHeight: 12 + header.height + 6 + root.listHeight + (moreText.visible ? moreText.implicitHeight + 18 : 12)
  property real bootEpochMs: 0

  Process {
    id: uptimeProc
    running: true
    command: ["cat", "/proc/uptime"]

    stdout: StdioCollector {
      onStreamFinished: root.bootEpochMs = Date.now() - parseFloat(text) * 1000
    }
  }

  Process {
    id: historyProc
    running: true
    command: ["dunstctl", "history"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const entries = JSON.parse(text).data[0] ?? []
          const next = entries.map(n => ({
            id: n.id.data,
            app_name: n.appname.data,
            summary: n.summary.data,
            body: n.body.data,
            icon_path: n.icon_path?.data ?? "",
            urls: (n.urls?.data ?? "").split(/\s+/).filter(u => u !== ""),
            time: root.bootEpochMs + n.timestamp.data / 1000
          }))
          if (JSON.stringify(next) !== JSON.stringify(root.notifications))
            root.notifications = next
        } catch (e) {
          root.notifications = []
        }
      }
    }
  }

  Process {
    id: clearProc
    command: ["dunstctl", "history-clear"]
  }

  Process {
    id: pauseProc
    command: ["dunstctl", "set-paused", "toggle"]
    onExited: pauseStateProc.running = true
  }

  Process {
    id: pauseStateProc
    command: ["dunstctl", "is-paused"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: dndButton.active = text.trim() === "true"
    }
  }

  onPanelOpenChanged: {
    if (root.panelOpen) pauseStateProc.running = true
  }

  Timer {
    interval: 50
    running: root.panelOpen
    repeat: true
    onTriggered: historyProc.running = true
  }

  Item {
    id: header
    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: parent.top
    anchors.topMargin: 12
    height: 31

    Text {
      id: notifTitle
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: "NOTIFICATIONS"
      color: root.config.accent
      font.family: root.config.barFont
      font.pixelSize: root.config.textBase
      font.weight: Font.Bold
    }

    Row {
      id: actionRow
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      Item {
        id: dndButton
        property bool active: false
        width: 28
        height: 28

        PillButton {
          anchors.fill: parent
          config: root.config
          text: dndButton.active ? "\udb80\udca0" : "\uf0f3"
          textColor: dndButton.active ? root.config.muted : root.config.accent
          pixelSize: root.config.textBase
          onClicked: pauseProc.running = true
        }
      }

      PillButton {
        height: 28
        config: root.config
        text: "CLEAR"
        textColor: root.config.panelText
        pixelSize: root.config.textXs
        letterSpacing: 1.5
        onClicked: clearProc.running = true
      }

    }
  }

  Text {
    id: moreText
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    height: visible ? implicitHeight : 0
    visible: root.notifications.length > root.collapsedCount
    z: 1
    text: root.expanded ? "Show less notifications  \uf077" : "Show more notifications  \uf078"
    color: root.config.muted
    font.family: root.config.barFont
    font.pixelSize: root.config.textXs

    MouseArea {
      anchors.fill: parent
      anchors.margins: -6
      cursorShape: Qt.PointingHandCursor
      onClicked: root.expanded = !root.expanded
    }
  }

  RecentNotificationList {
    id: notifList
    config: root.config
    notifications: root.notifications
    limit: root.expanded ? -1 : root.collapsedCount
    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: header.bottom
    anchors.topMargin: 6
    anchors.bottom: moreText.top
    anchors.bottomMargin: moreText.visible ? 8 : 2
  }

  Text {
    id: emptyText
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: header.bottom
    anchors.topMargin: 12
    visible: root.notifications.length === 0
    text: "No notifications"
    color: root.config.muted
    font.family: root.config.barFont
    font.pixelSize: root.config.textSm
  }
}
