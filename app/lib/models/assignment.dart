class Assignment {
  int? id;
  int subjectId;
  int teacherId;

  Assignment({
    this.id,
    required this.subjectId,
    required this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'teacher_id': teacherId,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      subjectId: map['subject_id'],
      teacherId: map['teacher_id'],
    );
  }
}
