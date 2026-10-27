import QtQuick

Rectangle {
  required property var config

  color: config.panelSurface
  radius: config.roundingPx
}
