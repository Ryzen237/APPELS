class Attendance {
  int? id;
  int? sessionId;
  int subjectId;
  int teacherId;
  String date;
  String? createdAt;

  Attendance({
    this.id,
    this.sessionId,
    required this.subjectId,
    required this.teacherId,
    required this.date,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      sessionId: map['session_id'],
      subjectId: map['subject_id'],
      teacherId: map['teacher_id'],
      date: map['date'],
      createdAt: map['created_at'],
    );
  }
}
