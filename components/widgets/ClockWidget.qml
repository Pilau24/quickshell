import Quickshell
import QtQuick
import "../core"

// qmllint disable unqualified
Item {
  id: root

  required property var screen
  required property var config
  required property int barHeight
  required property var slot

  property bool important: false
  visible: important || screen.name === config.resolvedPrimaryMonitor

  readonly property string timeText: Qt.formatTime(clock.date, "hh:mm:ss")

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Component {
    id: timeContent

    Text {
      text: root.timeText
      color: root.config.barText
      font.family: root.config.barFont
      font.pixelSize: root.config.barFontSize
      font.weight: root.config.barFontWeight
    }
  }

  implicitWidth: item.implicitWidth
  implicitHeight: item.implicitHeight

  WidgetItem {
    id: item
    config: root.config
    content: timeContent
    onClicked: panel.toggle()
  }

  WidgetPanel {
    id: panel
    targetScreen: root.screen
    config: root.config
    barHeight: root.barHeight
    slot: root.slot
    content: timeContent
  }
}
