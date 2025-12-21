enum EventNotifTypeEnum {
  checkInSuccess("assets/icons/ic_ticket_check.png"),
  eventStartSoon("assets/icons/ic_clock.png"),
  eventUpdate("assets/icons/ic_message_new.png"),
  fewSeatsLeft("assets/icons/ic_ticket_alert.png"),
  exclusiveEvent("assets/icons/ic_ticket_star.png"),
  eventUnregist("assets/icons/ic_ticket_x.png"),
  eventRegistration("assets/icons/ic_ticket_fav.png"),
  newEventAvailable("assets/icons/ic_ticket_cut.png"),
  shareFeedback("assets/icons/ic_feedback_star.png"),
  defaultIcon("assets/icons/ic_ticket_check.png");

  const EventNotifTypeEnum(this.type);

  final String type;

  static EventNotifTypeEnum getIcon(String type) {
    switch (type) {
      case 'CHECK IN SUCCESSFUL':
        return EventNotifTypeEnum.checkInSuccess;
      case 'EVENT START SOON':
        return EventNotifTypeEnum.eventStartSoon;
      case 'EVENT UPDATE':
        return EventNotifTypeEnum.eventUpdate;
      case 'FEW SEATS LEFT':
        return EventNotifTypeEnum.fewSeatsLeft;
      case 'EXCLUSIVE EVENT':
        return EventNotifTypeEnum.exclusiveEvent;
      case 'EVENT UNREGISTRATION':
        return EventNotifTypeEnum.eventUnregist;
      case 'EVENT REGISTRATION':
        return EventNotifTypeEnum.eventRegistration;
      case 'NEW EVENT AVAILABLE':
        return EventNotifTypeEnum.newEventAvailable;
      case 'SHARE FEEDBACK':
        return EventNotifTypeEnum.shareFeedback;
      default:
        return EventNotifTypeEnum.defaultIcon;
    }
  }
}