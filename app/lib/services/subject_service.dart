import '../database/database_helper.dart';
import '../models/models.dart';

class SubjectService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all subjects
  Future<List<Subject>> getAllSubjects() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  // Get subjects by semester
  Future<List<Subject>> getSubjectsBySemester(int semesterId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'semester_id = ?',
      whereArgs: [semesterId],
    );
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  // Get subjects assigned to teacher
  Future<List<Subject>> getSubjectsByTeacher(int teacherId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.* FROM subjects s
      INNER JOIN assignments a ON s.id = a.subject_id
      WHERE a.teacher_id = ?
    ''', [teacherId]);
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  // Create subject
  Future<int> createSubject(Subject subject) async {
    final db = await _dbHelper.database;
    return await db.insert('subjects', subject.toMap());
  }

  // Update subject
  Future<int> updateSubject(Subject subject) async {
    final db = await _dbHelper.database;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  // Delete subject
  Future<int> deleteSubject(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Assign subject to teacher
  Future<int> assignSubjectToTeacher(int subjectId, int teacherId) async {
    final db = await _dbHelper.database;
    final assignment = Assignment(subjectId: subjectId, teacherId: teacherId);
    return await db.insert('assignments', assignment.toMap());
  }

  // Remove assignment
  Future<int> removeAssignment(int subjectId, int teacherId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'assignments',
      where: 'subject_id = ? AND teacher_id = ?',
      whereArgs: [subjectId, teacherId],
    );
  }

  // Get assignments
  Future<List<Assignment>> getAllAssignments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('assignments');
    return List.generate(maps.length, (i) => Assignment.fromMap(maps[i]));
  }
}
