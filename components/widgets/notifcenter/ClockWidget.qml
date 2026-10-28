import Quickshell
import QtQuick
import "../../core"

// qmllint disable unqualified
Item {
  id: root

  required property var screen
  required property var config
  required property int barHeight
  required property var slot

  property bool important: false
  visible: important || screen.name === config.resolvedPrimaryMonitor

  readonly property string timeText: Qt.formatTime(systemClock.date, "hh:mm:ss")

  SystemClock {
    id: systemClock
    precision: SystemClock.Seconds
  }

  Component {
    id: timeContent

    Text {
      text: root.timeText
      color: root.config.barText
      font.family: root.config.barFont
      font.pixelSize: root.config.textSm
      font.weight: root.config.barFontWeight
    }
  }

  Component {
    id: panelContent

    ClockDashboard {
      config: root.config
      clock: systemClock
      panelOpen: panel.open
      maxHeight: root.screen.height - root.barHeight - 2 * root.config.panelMargin - root.config.panelPadding
    }
  }

  // Connections {
  //   target: root.config
  //   function onThemeLoadedChanged() {
  //     if (root.config.themeLoaded && root.visible && !panel.open) panel.toggle()
  //   }
  // }

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
    content: panelContent
    maxContentHeight: root.screen.height - root.barHeight - 2 * root.config.panelMargin
  }
}
