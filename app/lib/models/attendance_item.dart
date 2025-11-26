class AttendanceItem {
  int? id;
  int attendanceId;
  int studentId;
  String status; // 'present', 'absent', 'late'

  AttendanceItem({
    this.id,
    required this.attendanceId,
    required this.studentId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'student_id': studentId,
      'status': status,
    };
  }

  factory AttendanceItem.fromMap(Map<String, dynamic> map) {
    return AttendanceItem(
      id: map['id'],
      attendanceId: map['attendance_id'],
      studentId: map['student_id'],
      status: map['status'],
    );
  }
}
