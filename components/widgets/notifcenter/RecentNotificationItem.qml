import QtQuick
import Quickshell.Io

Rectangle {
  id: root

  required property var config
  required property var notification
  readonly property string iconScript: Qt.resolvedUrl("../../../scripts/app-icon.sh").toString().replace("file://", "")
  property string appIconPath: ""
  property bool menuOpen: false
  readonly property string appIconSource: appIconPath ? "file://" + appIconPath : ""
  readonly property real textBlock: root.config.textXs + root.config.textBase + root.config.textSm * 2
  readonly property real iconSize: Math.round(textBlock * 1.08)
  readonly property real pad: Math.round(textBlock * 0.3)
  readonly property real gap: Math.round(textBlock * 0.2)
  readonly property real iconGap: Math.round(textBlock * 0.35)
  readonly property real lineGap: Math.round(textBlock * 0.06)
  readonly property real inlineGap: Math.round(textBlock * 0.1)
  readonly property real menuWidth: Math.round(textBlock * 2.6)
  readonly property real menuRowHeight: Math.round(root.config.textXs * 2.4)

  Process {
    id: closeProc
    command: ["gdbus", "call", "--session", "--dest", "org.freedesktop.Notifications", "--object-path", "/org/freedesktop/Notifications", "--method", "org.freedesktop.Notifications.CloseNotification", String(root.notification.id)]
  }

  Process {
    id: historyRmProc
    command: ["dunstctl", "history-rm", String(root.notification.id)]
  }

  Process {
    id: openProc
  }

  function runMenuAction(action) {
    if (action === "dismiss") {
      closeProc.running = true
      historyRmProc.running = true
    } else {
      openProc.command = ["xdg-open", action]
      openProc.running = true
    }
    root.menuOpen = false
  }

  Process {
    id: iconProc
    command: ["bash", root.iconScript, root.notification.app_name]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.appIconPath = text.trim()
    }
  }

  color: root.config.barBackground
  radius: root.config.roundingPx
  border.width: 1
  border.color: Qt.alpha(root.config.muted, 0.25)
  height: Math.max(content.implicitHeight, iconSize) + pad * 2

  function timeAgo(ms) {
    const mins = Math.floor((Date.now() - ms) / 60000)
    if (mins < 60) return Math.max(mins, 0) + "m ago"
    const hours = Math.floor(mins / 60)
    if (hours < 24) return hours + "h ago"
    const days = Math.floor(hours / 24)
    if (days === 1) return "yesterday"
    if (days <= 7) return days + " days ago"
    return Qt.formatDateTime(new Date(ms), "d MMM yyyy")
  }

  Rectangle {
    id: appIcon
    anchors.left: parent.left
    anchors.leftMargin: root.pad
    anchors.top: parent.top
    anchors.topMargin: root.pad
    width: root.iconSize
    height: root.iconSize
    radius: root.config.roundingPx
    color: appIconImage.status === Image.Ready ? "transparent" : Qt.alpha(root.config.accent, 0.2)
    clip: true

    Image {
      id: appIconImage
      anchors.fill: parent
      source: root.appIconSource
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      visible: status === Image.Ready
    }

    Text {
      anchors.centerIn: parent
      visible: appIconImage.status !== Image.Ready
      text: root.notification.app_name.charAt(0).toUpperCase()
      color: root.config.accent
      font.family: root.config.barFont
      font.pixelSize: root.config.textLg
      font.weight: root.config.barFontWeight
    }
  }

  Column {
    id: content
    anchors.left: appIcon.right
    anchors.leftMargin: root.iconGap
    anchors.right: menuDots.left
    anchors.rightMargin: root.gap
    anchors.top: appIcon.top
    spacing: root.lineGap

    Item {
      id: appRow
      width: content.width
      height: Math.max(appText.implicitHeight, timeText.y + timeText.implicitHeight)

      Text {
        id: appText
        x: 0
        width: Math.min(implicitWidth, appRow.width - timeText.implicitWidth - root.inlineGap)
        text: root.notification.app_name.toUpperCase()
        color: root.config.accent
        font.family: root.config.barFont
        font.pixelSize: root.config.textXs
        font.weight: Font.Bold
        elide: Text.ElideRight
      }

      Text {
        id: timeText
        x: appText.width + root.inlineGap
        y: appText.baselineOffset - timeText.baselineOffset
        text: "• " + root.timeAgo(root.notification.time)
        color: root.config.muted
        font.family: root.config.barFont
        font.pixelSize: root.config.textSm
      }
    }

    Text {
      width: content.width
      text: root.notification.summary
      color: root.config.panelText
      font.family: root.config.barFont
      font.pixelSize: root.config.textSm
      font.weight: Font.Bold
      elide: Text.ElideRight
    }

    Text {
      width: content.width
      text: root.notification.body.replace(/\n/g, " ")
      color: root.config.muted
      font.family: root.config.barFont
      font.pixelSize: root.config.textXs
      wrapMode: Text.Wrap
      maximumLineCount: 2
      elide: Text.ElideRight
    }
  }

  Text {
    id: menuDots
    anchors.right: parent.right
    anchors.rightMargin: root.pad
    anchors.top: content.top
    anchors.topMargin: appText.baselineOffset - baselineOffset
    text: "\uf141"
    color: root.config.muted
    font.family: root.config.barFont
    font.pixelSize: root.config.textSm
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: closeProc.running = true
  }

  MouseArea {
    anchors.fill: menuDots
    anchors.margins: -6
    cursorShape: Qt.PointingHandCursor
    onClicked: root.menuOpen = !root.menuOpen
  }

  Rectangle {
    id: menuPopup
    visible: root.menuOpen
    z: 2
    anchors.top: menuDots.bottom
    anchors.topMargin: 4
    anchors.right: parent.right
    anchors.rightMargin: root.pad
    width: root.menuWidth
    height: menuColumn.implicitHeight + 8
    radius: root.config.roundingPx
    color: root.config.panelSurface
    border.width: 1
    border.color: Qt.alpha(root.config.muted, 0.25)

    Column {
      id: menuColumn
      anchors.fill: parent
      anchors.margins: 4

      Repeater {
        model: (root.notification.urls ?? []).concat(["dismiss"])

        delegate: Rectangle {
          required property var modelData
          width: menuColumn.width
          height: root.menuRowHeight
          radius: root.config.roundingPx
          color: rowArea.containsMouse ? Qt.alpha(root.config.muted, 0.2) : "transparent"

          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.gap
            anchors.right: parent.right
            anchors.rightMargin: root.gap
            text: modelData === "dismiss" ? "Dismiss" : "Open page  " + modelData
            color: root.config.panelText
            font.family: root.config.barFont
            font.pixelSize: root.config.textXs
            font.weight: root.config.barFontWeight
            elide: Text.ElideRight
          }

          MouseArea {
            id: rowArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.runMenuAction(modelData)
          }
        }
      }
    }
  }
}
