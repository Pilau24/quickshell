import QtQuick

Item {
  id: root

  required property var config
  required property var clock
  property bool panelOpen: false
  property int maxHeight: 432

  implicitWidth: 280
  implicitHeight: root.shownHeight
  clip: true

  readonly property real calendarBottom: calendarCard.y + calendarCard.height + 8
  readonly property real targetHeight: Math.min(root.maxHeight, root.calendarBottom + (notifCard.expanded ? notifCard.expandedHeight : notifCard.collapsedHeight))
  property real shownHeight: root.targetHeight

  Behavior on shownHeight {
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
    panelOpen: root.panelOpen
    anchors.top: calendarCard.bottom
    anchors.topMargin: 8
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.targetHeight - root.calendarBottom
  }
}
