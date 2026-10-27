import QtQuick
import QtQuick.Controls

Flickable {
  id: root

  required property var config
  property var notifications: []
  property int limit: -1
  property real wheelSpeed: 0.8
  readonly property real itemsHeight: column.height

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
      root.contentY = Math.max(0, Math.min(maxY, root.contentY - event.angleDelta.y * root.wheelSpeed));
    }
  }

  ScrollBar.vertical: ScrollBar {
    policy: root.limit < 0 ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
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
    width: root.width - 6
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
