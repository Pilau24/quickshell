import QtQuick

Rectangle {
  id: root

  required property var config
  required property var notification

  color: root.config.barBackground
  radius: root.config.roundingPx
  border.width: 1
  border.color: Qt.alpha(root.config.muted, 0.25)
  height: Math.max(content.implicitHeight, 28) + 16

  Rectangle {
    id: appIcon
    anchors.left: parent.left
    anchors.leftMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    width: 28
    height: 28
    radius: root.config.roundingPx
    color: Qt.alpha(root.config.accent, 0.2)

    Text {
      anchors.centerIn: parent
      text: root.notification.app_name.charAt(0).toUpperCase()
      color: root.config.accent
      font.family: root.config.barFont
      font.pixelSize: root.config.textXs
      font.weight: root.config.barFontWeight
    }
  }

  Column {
    id: content
    anchors.left: appIcon.right
    anchors.leftMargin: 10
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    spacing: 2

    Text {
      width: content.width
      text: root.notification.app_name.toUpperCase()
      color: root.config.accent
      font.family: root.config.barFont
      font.pixelSize: root.config.textXs
      elide: Text.ElideRight
    }

    Text {
      width: content.width
      text: root.notification.summary
      color: root.config.panelText
      font.family: root.config.barFont
      font.pixelSize: root.config.textXs
      elide: Text.ElideRight
    }

    Text {
      width: content.width
      text: root.notification.body.replace(/\n/g, " ")
      color: root.config.muted
      font.family: root.config.barFont
      font.pixelSize: root.config.textXs
      elide: Text.ElideRight
    }
  }
}
