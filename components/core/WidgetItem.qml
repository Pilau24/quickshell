import QtQuick

Rectangle {
  id: root

  required property var config
  property Component content
  property real cornerScale: 1
  signal clicked()

  implicitWidth: loader.implicitWidth + 16
  implicitHeight: root.config.barHeight
  color: root.config.barBackground
  radius: root.config.roundingFactor * root.cornerScale

  Loader {
    id: loader
    anchors.centerIn: parent
    sourceComponent: root.content
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
  }
}
