import QtQuick

// Rounded, bordered button with a hover highlight. Set text, textColor, and pixelSize per use.
Rectangle {
  id: root

  required property var config
  property int horizontalPadding: 13
  property alias text: label.text
  property alias textColor: label.color
  property alias pixelSize: label.font.pixelSize
  property alias letterSpacing: label.font.letterSpacing
  signal clicked()

  implicitWidth: label.implicitWidth + horizontalPadding * 2
  radius: config.roundingPx
  color: area.containsMouse ? Qt.alpha(config.muted, 0.35) : Qt.alpha(config.muted, 0.15)
  border.width: 1
  border.color: Qt.alpha(config.muted, 0.3)

  Text {
    id: label
    anchors.centerIn: parent
    font.family: root.config.barFont
    font.weight: root.config.barFontWeight
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
