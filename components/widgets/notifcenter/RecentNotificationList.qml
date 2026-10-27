import QtQuick
import QtQuick.Controls

Flickable {
  id: root

  required property var config
  property var notifications: []
  property int limit: -1
  property real wheelSpeed: 0.8
  property real targetY: 0
  readonly property real itemsHeight: column.height
  readonly property bool overflowing: column.height > root.height + 1

  clip: true
  contentWidth: width
  contentHeight: column.height
  boundsBehavior: Flickable.StopAtBounds
  // Disabled so the WheelHandler below fully controls wheel scrolling.
  interactive: false

  WheelHandler {
    target: null
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: event => {
      const maxY = Math.max(0, root.contentHeight - root.height);
      root.targetY = Math.max(0, Math.min(maxY, root.targetY - event.angleDelta.y * root.wheelSpeed));
      root.contentY = root.targetY;
    }
  }

  Behavior on contentY {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }

  ScrollBar.vertical: ScrollBar {
    policy: root.overflowing ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    contentItem: Rectangle {
      implicitWidth: 4
      radius: 2
      color: root.config.muted
    }
    background: Rectangle {
      implicitWidth: 6
      color: "transparent"
    }
  }

  Column {
    id: column
    width: root.width - (root.overflowing ? 6 : 0)
    spacing: 6

    Repeater {
      model: root.limit < 0 ? root.notifications : root.notifications.slice(0, root.limit)

      delegate: RecentNotificationItem {
        required property var modelData
        width: column.width
        config: root.config
        notification: modelData
      }
    }
  }
}
