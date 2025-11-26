import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'attendance_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password_hash TEXT,
        role TEXT NOT NULL,
        display_name TEXT,
        created_at TEXT
      )
    ''');

    // Create semester table
    await db.execute('''
      CREATE TABLE semester (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        start_date TEXT,
        end_date TEXT
      )
    ''');

    // Create subjects table
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject_area TEXT NOT NULL,
        level INTEGER NOT NULL CHECK(level >= 3 AND level <= 5),
        axis TEXT NOT NULL CHECK(axis IN ('GLO', 'GRT')),
        semester_id INTEGER,
        sessions_per_week INTEGER DEFAULT 0,
        FOREIGN KEY (semester_id) REFERENCES semester(id),
        UNIQUE(name, subject_area, level, axis)
      )
    ''');

    // Create students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        subject_area TEXT NOT NULL,
        level INTEGER NOT NULL CHECK(level >= 3 AND level <= 5),
        axis TEXT NOT NULL CHECK(axis IN ('GLO', 'GRT')),
        created_at TEXT,
        UNIQUE(firstname, lastname, subject_area, level, axis)
      )
    ''');

    // Create assignments table
    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER,
        teacher_id INTEGER,
        FOREIGN KEY (subject_id) REFERENCES subjects(id),
        FOREIGN KEY (teacher_id) REFERENCES users(id)
      )
    ''');

    // Create sessions table
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER,
        name TEXT,
        scheduled_weekday INTEGER,
        FOREIGN KEY (subject_id) REFERENCES subjects(id)
      )
    ''');

    // Create attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        subject_id INTEGER,
        teacher_id INTEGER,
        date TEXT,
        created_at TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(id),
        FOREIGN KEY (teacher_id) REFERENCES users(id)
      )
    ''');

    // Create attendance_items table
    await db.execute('''
      CREATE TABLE attendance_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attendance_id INTEGER,
        student_id INTEGER,
        status TEXT,
        FOREIGN KEY (attendance_id) REFERENCES attendance(id),
        FOREIGN KEY (student_id) REFERENCES students(id)
      )
    ''');

    // Insert default users for different roles
    await db.insert('users', {
      'email': 'teacher@university.edu',
      'password_hash': 'teacher123',
      'role': 'teacher',
      'display_name': 'John Smith',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'cdd@university.edu',
      'password_hash': 'cdd123',
      'role': 'cdd',
      'display_name': 'Dr MAKA MAKA Ebenezer',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'director@university.edu',
      'password_hash': 'director123',
      'role': 'director',
      'display_name': 'Pr Ruben MOUANGUE',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert some sample subjects - each subject covers multiple levels/axes now
    await db.insert('subjects', {
      'name': 'Mathematics',
      'subject_area': 'Mathematics',
      'level': 3,
      'axis': 'GLO',
      'semester_id': 1,
      'sessions_per_week': 3,
    });

    await db.insert('subjects', {
      'name': 'Physics',
      'subject_area': 'Physics',
      'level': 4,
      'axis': 'GLO',
      'semester_id': 1,
      'sessions_per_week': 2,
    });

    await db.insert('subjects', {
      'name': 'Computer Science',
      'subject_area': 'Computer Science',
      'level': 5,
      'axis': 'GRT',
      'semester_id': 1,
      'sessions_per_week': 4,
    });

    // Insert sample students grouped by level and axis
    await _insertSampleStudents(db);

    // Insert a sample semester
    await db.insert('semester', {
      'name': 'Fall 2024',
      'start_date': '2024-09-01',
      'end_date': '2024-12-20',
    });
  }

  static Future<void> _insertSampleStudents(Database db) async {
    // Mathematics students - Level 3, GLO
    await db.insert('students', {
      'firstname': 'Alice',
      'lastname': 'Johnson',
      'subject_area': 'Mathematics',
      'level': 3,
      'axis': 'GLO',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('students', {
      'firstname': 'Bob',
      'lastname': 'Smith',
      'subject_area': 'Mathematics',
      'level': 3,
      'axis': 'GLO',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Mathematics students - Level 3, GRT
    await db.insert('students', {
      'firstname': 'Charlie',
      'lastname': 'Brown',
      'subject_area': 'Mathematics',
      'level': 3,
      'axis': 'GRT',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Physics students - Level 4, GLO
    await db.insert('students', {
      'firstname': 'Diana',
      'lastname': 'Wilson',
      'subject_area': 'Physics',
      'level': 4,
      'axis': 'GLO',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('students', {
      'firstname': 'Eve',
      'lastname': 'Davis',
      'subject_area': 'Physics',
      'level': 4,
      'axis': 'GLO',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Computer Science students - Level 5, GRT
    await db.insert('students', {
      'firstname': 'Frank',
      'lastname': 'Miller',
      'subject_area': 'Computer Science',
      'level': 5,
      'axis': 'GRT',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('students', {
      'firstname': 'Grace',
      'lastname': 'Garcia',
      'subject_area': 'Computer Science',
      'level': 5,
      'axis': 'GRT',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
