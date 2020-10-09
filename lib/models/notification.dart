class EventNotification {
  EventNotification({this.time, this.message, this.description, this.value});

  final String time;
  final String message;
  final String description;
  final String value;
  EventNotification copyWith({String time, String message, String description, String value}) =>
      EventNotification(
          time: time ?? this.time,
          message: message ?? this.message,
          description: description ?? this.description,
          value: value ?? value);

  factory EventNotification.fromJson(Map<String, dynamic> json) => EventNotification(
      time: json["time"] == null ? null : json["time"],
      message: json["message"] == null ? null : json["message"],
      description: json["description"] == null ? null : json["description"],
      value: json['value'] == null ? null : json['value']);

  Map<String, dynamic> toJson() => {
        "time": time == null ? null : time,
        "message": message == null ? null : message,
        "description": description == null ? null : description,
        "value": value == null ? null : value,
      };

  EventNotification change({String duration, String dateTime, String value}) {
    Duration parsedDuration = Duration(milliseconds: int.parse(duration));
    DateTime parsedDateTime = DateTime.fromMicrosecondsSinceEpoch(int.parse(dateTime));
    DateTime notificationTime = parsedDateTime.subtract(parsedDuration);
    return copyWith(time: notificationTime.millisecondsSinceEpoch.toString(), value: value);
  }
}
