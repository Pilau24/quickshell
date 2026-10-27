import QtQuick

Item {
  id: root

  required property var config
  required property var clock
  property int maxHeight: 432

  implicitWidth: 280
  implicitHeight: notifCard.expanded ? root.maxHeight : calendarCard.y + calendarCard.height + 8 + notifCard.collapsedHeight

  Behavior on implicitHeight {
    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
  }

  ClockBanner {
    id: banner
    config: root.config
    now: root.clock.date
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 120
  }

  CalendarCard {
    id: calendarCard
    config: root.config
    today: root.clock.date
    anchors.top: banner.bottom
    anchors.topMargin: 8
    anchors.left: parent.left
    anchors.right: parent.right
  }

  RecentNotificationsCard {
    id: notifCard
    config: root.config
    anchors.top: calendarCard.bottom
    anchors.topMargin: 8
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
  }
}
