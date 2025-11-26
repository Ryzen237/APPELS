class Session {
  int? id;
  int subjectId;
  String? name;
  int? scheduledWeekday; // 1-7 for Monday-Sunday

  Session({
    this.id,
    required this.subjectId,
    this.name,
    this.scheduledWeekday,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'scheduled_weekday': scheduledWeekday,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      subjectId: map['subject_id'],
      name: map['name'],
      scheduledWeekday: map['scheduled_weekday'],
    );
  }
}
