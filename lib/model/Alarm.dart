class Alarm {
  final String notificationID;
  final String content;
  final String interval;
  final String startTime;
  final bool active;

  Alarm({
    this.notificationID,
    this.content,
    this.startTime,
    this.interval,
    this.active,
  });

  String get getName => content;
  String get getInterval => interval;
  String get getStartTime => startTime;
  String get getID => notificationID;

  Map<String, dynamic> toJson() {
    return {
      "id": this.notificationID,
      "content": this.content,
      "interval": this.interval,
      "start": this.startTime,
      "active": this.active,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> parsedJson) {
    return Alarm(
      notificationID: parsedJson['id'],
      content: parsedJson['content'],
      interval: parsedJson['interval'],
      startTime: parsedJson['start'],
      active: parsedJson['active'],
    );
  }
}
