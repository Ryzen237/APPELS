import '../database/database_helper.dart';
import '../models/models.dart';

class AttendanceService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create attendance record
  Future<int> createAttendance(Attendance attendance) async {
    final db = await _dbHelper.database;
    final newAttendance = Attendance(
      sessionId: attendance.sessionId,
      subjectId: attendance.subjectId,
      teacherId: attendance.teacherId,
      date: attendance.date,
      createdAt: DateTime.now().toIso8601String(),
    );
    return await db.insert('attendance', newAttendance.toMap());
  }

  // Add attendance items for students
  Future<void> addAttendanceItems(int attendanceId, List<AttendanceItem> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      final newItem = AttendanceItem(
        attendanceId: attendanceId,
        studentId: item.studentId,
        status: item.status,
      );
      batch.insert('attendance_items', newItem.toMap());
    }
    await batch.commit();
  }

  // Get attendance records for a subject
  Future<List<Attendance>> getAttendanceBySubject(int subjectId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  // Get attendance items for an attendance record
  Future<List<AttendanceItem>> getAttendanceItems(int attendanceId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_items',
      where: 'attendance_id = ?',
      whereArgs: [attendanceId],
    );
    return List.generate(maps.length, (i) => AttendanceItem.fromMap(maps[i]));
  }

  // Calculate attendance rate for a student in a subject
  Future<double> getStudentAttendanceRate(int studentId, int subjectId) async {
    final db = await _dbHelper.database;

    // Get total attendance records for the subject
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM attendance WHERE subject_id = ?
    ''', [subjectId]);
    final totalRecords = totalResult.first['count'] as int;

    if (totalRecords == 0) return 0.0;

    // Get present count for the student
    final presentResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM attendance_items ai
      INNER JOIN attendance a ON ai.attendance_id = a.id
      WHERE ai.student_id = ? AND a.subject_id = ? AND ai.status = 'present'
    ''', [studentId, subjectId]);
    final presentCount = presentResult.first['count'] as int;

    return (presentCount / totalRecords) * 100;
  }

  // Calculate teacher attendance rate (average across subjects)
  Future<double> getTeacherAttendanceRate(int teacherId) async {
    final db = await _dbHelper.database;

    // Get all subjects assigned to teacher
    final subjects = await db.rawQuery('''
      SELECT DISTINCT s.id FROM subjects s
      INNER JOIN assignments a ON s.id = a.subject_id
      WHERE a.teacher_id = ?
    ''', [teacherId]);

    if (subjects.isEmpty) return 0.0;

    double totalRate = 0.0;
    int subjectCount = 0;

    for (var subject in subjects) {
      final subjectId = subject['id'] as int;

      // Get all students for this subject (assuming all students attend all subjects)
      final students = await db.query('students');
      if (students.isEmpty) continue;

      double subjectRate = 0.0;
      for (var student in students) {
        final studentId = student['id'] as int;
        subjectRate += await getStudentAttendanceRate(studentId, subjectId);
      }
      subjectRate /= students.length;

      totalRate += subjectRate;
      subjectCount++;
    }

    return subjectCount > 0 ? totalRate / subjectCount : 0.0;
  }

  // Get attendance history for teacher
  Future<List<Map<String, dynamic>>> getTeacherAttendanceHistory(int teacherId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT a.*, s.name as subject_name, COUNT(ai.id) as total_students,
             SUM(CASE WHEN ai.status = 'present' THEN 1 ELSE 0 END) as present_count
      FROM attendance a
      INNER JOIN subjects s ON a.subject_id = s.id
      LEFT JOIN attendance_items ai ON a.id = ai.attendance_id
      WHERE a.teacher_id = ?
      GROUP BY a.id
      ORDER BY a.date DESC
    ''', [teacherId]);

    return results;
  }

  // Get attendance report by subject
  Future<List<Map<String, dynamic>>> getAttendanceReportBySubject(int subjectId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT st.firstname, st.lastname,
             COUNT(ai.id) as total_sessions,
             SUM(CASE WHEN ai.status = 'present' THEN 1 ELSE 0 END) as present_count,
             ROUND(
               (SUM(CASE WHEN ai.status = 'present' THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(ai.id), 0),
               2
             ) as attendance_rate
      FROM attendance a
      INNER JOIN students st ON 1=1
      LEFT JOIN attendance_items ai ON st.id = ai.student_id AND a.id = ai.attendance_id
      WHERE a.subject_id = ?
      GROUP BY st.id, st.firstname, st.lastname
      ORDER BY attendance_rate DESC
    ''', [subjectId]);

    return results;
  }
}
