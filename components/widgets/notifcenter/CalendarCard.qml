import QtQuick
import "../../ui"

Card {
  id: root

  required property date today

  readonly property real cellWidth: (width - 24) / 7
  height: grid.y + grid.height + 12
  readonly property string todayKey: Qt.formatDate(today, "yyyy-MM-dd")
  property int viewOffset: 0

  onTodayKeyChanged: viewOffset = 0

  function firstOfShown() {
    return new Date(root.today.getFullYear(), root.today.getMonth() + root.viewOffset, 1)
  }

  function cellDate(i) {
    var first = root.firstOfShown()
    return new Date(first.getFullYear(), first.getMonth(), 1 - first.getDay() + i)
  }

  Item {
    id: navRow
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 12
    height: 24

      Rectangle {
        x: (root.cellWidth - width) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: root.config.roundingPx
        color: prevArea.containsMouse ? Qt.alpha(root.config.muted, 0.35) : Qt.alpha(root.config.muted, 0.15)

        Text {
          anchors.centerIn: parent
          text: "\uf060"
          color: root.config.panelText
          font.family: root.config.barFont
          font.pixelSize: root.config.textSm
        }

        MouseArea {
          id: prevArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.viewOffset--
        }
      }

      Text {
        anchors.centerIn: parent
        text: Qt.formatDate(root.firstOfShown(), "MMMM yyyy")
        color: root.config.panelText
        font.family: root.config.barFont
        font.pixelSize: root.config.textSm
        font.weight: root.config.barFontWeight
      }

      Rectangle {
        x: parent.width - root.cellWidth + (root.cellWidth - width) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: root.config.roundingPx
        color: nextArea.containsMouse ? Qt.alpha(root.config.muted, 0.35) : Qt.alpha(root.config.muted, 0.15)

        Text {
          anchors.centerIn: parent
          text: "\uf061"
          color: root.config.panelText
          font.family: root.config.barFont
          font.pixelSize: root.config.textSm
        }

        MouseArea {
          id: nextArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.viewOffset++
        }
      }
    }

    Row {
      id: weekRow
      anchors.top: navRow.bottom
      anchors.topMargin: 6
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 12
      anchors.rightMargin: 12

      Repeater {
        model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        Text {
          width: root.cellWidth
          height: 16
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: modelData
          color: root.config.muted
          font.family: root.config.barFont
          font.pixelSize: root.config.textXs
        }
      }
    }

    Grid {
      id: grid
      anchors.top: weekRow.bottom
      anchors.topMargin: 6
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      columns: 7

      Repeater {
        model: 42

        Item {
          id: dayCell
          required property int index
          readonly property var cell: root.cellDate(index)
          readonly property bool isToday: Qt.formatDate(cell, "yyyy-MM-dd") === root.todayKey

          width: root.cellWidth
          height: 24

          Rectangle {
            anchors.centerIn: parent
            width: 22
            height: 22
            radius: 11
            color: root.config.accent
            visible: dayCell.isToday
          }

          Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: dayCell.cell.getDate()
            color: dayCell.isToday ? root.config.barBackground : dayCell.cell.getMonth() === root.firstOfShown().getMonth() ? root.config.panelText : root.config.muted
            font.family: root.config.barFont
            font.pixelSize: root.config.textSm
            font.weight: root.config.barFontWeight
          }
        }
      }
    }
}
