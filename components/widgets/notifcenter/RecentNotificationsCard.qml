import QtQuick
import Quickshell.Io
import "../../ui"

Card {
  id: root

  property var notifications: []
  property bool expanded: false
  readonly property int collapsedCount: 3
  readonly property real collapsedHeight: 12 + header.height + 6 + notifList.itemsHeight + (moreText.visible ? moreText.implicitHeight + 18 : 12)

  Process {
    id: historyProc
    running: true
    command: ["makoctl", "history", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.notifications = JSON.parse(text)
        } catch (e) {
          root.notifications = []
        }
      }
    }
  }

  Timer {
    interval: 10000
    running: true
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
    height: 22

    Row {
      id: titleRow
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      Item {
        id: dndButton
        property bool active: false
        width: 22
        height: 22

        Text {
          id: dndLabel
          anchors.centerIn: parent
          text: dndButton.active ? "\udb80\udca0" : "\uf0f3"
          color: dndButton.active ? root.config.accent : root.config.muted
          font.family: root.config.barFont
          font.pixelSize: root.config.textSm
          font.weight: root.config.barFontWeight
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: dndButton.active = !dndButton.active
        }
      }

      Text {
        id: notifTitle
        height: 22
        verticalAlignment: Text.AlignVCenter
        text: "NOTIFICATIONS"
        color: root.config.accent
        font.family: root.config.barFont
        font.pixelSize: root.config.textSm
        font.weight: root.config.barFontWeight
      }
    }

    Row {
      id: actionRow
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      Rectangle {
        id: clearPill
        height: 18
        width: clearLabel.implicitWidth
        radius: root.config.roundingPx
        color: "transparent"

        Text {
          id: clearLabel
          anchors.centerIn: parent
          text: "CLEAR"
          color: root.config.muted
          font.family: root.config.barFont
          font.pixelSize: root.config.textXs
          font.weight: root.config.barFontWeight
        }
      }

      Rectangle {
        id: togglePill
        visible: root.notifications.length > root.collapsedCount
        height: 18
        width: Math.max(collapseMetrics.width, showAllMetrics.width) + 12
        radius: root.config.roundingPx
        color: "transparent"

        TextMetrics {
          id: collapseMetrics
          font: toggleLabel.font
          text: "COLLAPSE"
        }

        TextMetrics {
          id: showAllMetrics
          font: toggleLabel.font
          text: "SHOW ALL"
        }

        Text {
          id: toggleLabel
          anchors.centerIn: parent
          text: root.expanded ? "COLLAPSE" : "SHOW ALL"
          color: root.config.accent
          font.family: root.config.barFont
          font.pixelSize: root.config.textXs
          font.weight: root.config.barFontWeight
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.expanded = !root.expanded
        }
      }
    }
  }

  Text {
    id: moreText
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    height: visible ? implicitHeight : 0
    visible: !root.expanded && root.notifications.length > root.collapsedCount
    text: "More notifications available  \uf078"
    color: root.config.muted
    font.family: root.config.barFont
    font.pixelSize: root.config.textXs

    MouseArea {
      anchors.fill: parent
      anchors.margins: -6
      cursorShape: Qt.PointingHandCursor
      onClicked: root.expanded = true
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
}
