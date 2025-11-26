class Student {
  int? id;
  String firstname;
  String lastname;
  String subjectArea; // e.g., 'Mathematics', 'Physics', 'Computer Science'
  int level; // 3, 4, or 5
  String axis; // 'GLO' or 'GRT'
  String? createdAt;

  Student({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.subjectArea,
    required this.level,
    required this.axis,
    this.createdAt,
  });

  String get fullName => '$firstname $lastname';

  // Validate level and axis values
  bool isValid() {
    return level >= 3 && level <= 5 && (axis == 'GLO' || axis == 'GRT');
  }

  // Get grouping key for attendance management
  String get groupingKey => '${subjectArea}_${level}_${axis}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'subject_area': subjectArea,
      'level': level,
      'axis': axis,
      'created_at': createdAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      firstname: map['firstname'],
      lastname: map['lastname'],
      subjectArea: map['subject_area'] ?? 'Unassigned', // Fallback for legacy data
      level: map['level'] ?? 3, // Default to level 3 for legacy data
      axis: map['axis'] ?? 'GLO', // Default to GLO for legacy data
      createdAt: map['created_at'],
    );
  }
}
