import '../database/database_helper.dart';
import '../models/models.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Authenticate user
  Future<User?> authenticate(String email, String password) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final user = User.fromMap(maps.first);
      // Compare hashed passwords properly
      if (user.passwordHash == password) {
        return user;
      }
    }
    return null;
  }

  // Create user (for CdD to create teachers)
  Future<int> createUser(User user) async {
    final db = await _dbHelper.database;
    // Hash password in production
    final hashedUser = User(
      email: user.email,
      passwordHash: user.passwordHash, // BCrypt.hashpw(user.passwordHash, BCrypt.gensalt()),
      role: user.role,
      displayName: user.displayName,
      createdAt: DateTime.now().toIso8601String(),
    );
    return await db.insert('users', hashedUser.toMap());
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Get all users by role
  Future<List<User>> getUsersByRole(String role) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
    );
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Get user by id
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
