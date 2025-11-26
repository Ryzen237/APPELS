import '../database/database_helper.dart';
import '../models/models.dart';

class StudentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all students
  Future<List<Student>> getAllStudents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // Create student
  Future<int> createStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.insert('students', student.toMap());
  }

  // Get student by id
  Future<Student?> getStudentById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  // Update student
  Future<int> updateStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // Delete student
  Future<int> deleteStudent(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
