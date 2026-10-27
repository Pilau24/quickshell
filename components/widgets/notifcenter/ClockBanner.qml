import QtQuick
import "../../ui"

Card {
  id: root

  required property date now

  readonly property string greeting: {
    var h = root.now.getHours()
    if (h < 6) return "GOOD NIGHT"
    if (h < 12) return "GOOD MORNING"
    if (h < 18) return "GOOD AFTERNOON"
    return "GOOD EVENING"
  }

  Text {
    id: dateText
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: parent.top
    anchors.topMargin: 12
    text: Qt.formatDate(root.now, "dddd · MMMM d, yyyy").toUpperCase()
    color: root.config.accent
    font.family: root.config.barFont
    font.pixelSize: root.config.textSm
    font.weight: root.config.barFontWeight
  }

  Item {
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.top: dateText.bottom
    anchors.bottom: greetingText.top
    width: timeText.width + 10 + apText.width

    Text {
      id: timeText
      anchors.verticalCenter: parent.verticalCenter
      text: Qt.formatTime(root.now, "hh:mm:ss")
      color: root.config.panelText
      font.family: root.config.barFont
      font.pixelSize: 40
      font.weight: root.config.barFontWeight
    }

    Text {
      id: apText
      anchors.left: timeText.right
      anchors.leftMargin: 10
      anchors.baseline: timeText.baseline
      text: Qt.formatTime(root.now, "AP")
      color: root.config.panelText
      font.family: root.config.barFont
      font.pixelSize: root.config.textXl
      font.weight: root.config.barFontWeight
    }
  }

  Text {
    id: greetingText
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 12
    text: root.greeting + " · STAY PRODUCTIVE"
    color: root.config.muted
    font.family: root.config.barFont
    font.pixelSize: root.config.textXs
  }
}
