class Subject {
  int? id;
  String name;
  String subjectArea;
  int level;
  String axis;
  int? semesterId;
  int sessionsPerWeek;

  Subject({
    this.id,
    required this.name,
    required this.subjectArea,
    required this.level,
    required this.axis,
    this.semesterId,
    this.sessionsPerWeek = 0,
  });

  // Grouping key for attendance management
  String get groupingKey => '${subjectArea}_${level}_${axis}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject_area': subjectArea,
      'level': level,
      'axis': axis,
      'semester_id': semesterId,
      'sessions_per_week': sessionsPerWeek,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      subjectArea: map['subject_area'] ?? map['name'] ?? 'Unknown', // Fallback for legacy data
      level: map['level'] ?? 3, // Default to level 3 for legacy data
      axis: map['axis'] ?? 'GLO', // Default to GLO for legacy data
      semesterId: map['semester_id'],
      sessionsPerWeek: map['sessions_per_week'] ?? 0,
    );
  }
}
