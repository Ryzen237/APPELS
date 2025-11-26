class Schedule {
  int? id;
  int teacherId;
  String dayOfWeek; // 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  String timeSlot; // 'morning' or 'afternoon'
  String subjectName;
  String subjectArea;
  int level;
  String axis;
  int durationHours; // 4 hours per slot

  Schedule({
    this.id,
    required this.teacherId,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.subjectName,
    required this.subjectArea,
    required this.level,
    required this.axis,
    this.durationHours = 4,
  });

  // Validate schedule constraints
  bool isValid() {
    // Only Monday to Saturday
    final validDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    if (!validDays.contains(dayOfWeek)) {
      return false;
    }

    // Only morning and afternoon slots
    if (timeSlot != 'morning' && timeSlot != 'afternoon') {
      return false;
    }

    // Duration must be 4 hours
    if (durationHours != 4) {
      return false;
    }

    return true;
  }

  // Get day index for sorting (Monday = 1, Tuesday = 2, etc.)
  int get dayIndex {
    switch (dayOfWeek) {
      case 'Monday': return 1;
      case 'Tuesday': return 2;
      case 'Wednesday': return 3;
      case 'Thursday': return 4;
      case 'Friday': return 5;
      case 'Saturday': return 6;
      default: return 7;
    }
  }

  // Get schedule identifier for grouping
  String get scheduleKey => '${teacherId}_${dayOfWeek}_${timeSlot}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'day_of_week': dayOfWeek,
      'time_slot': timeSlot,
      'subject_name': subjectName,
      'subject_area': subjectArea,
      'level': level,
      'axis': axis,
      'duration_hours': durationHours,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      teacherId: map['teacher_id'],
      dayOfWeek: map['day_of_week'],
      timeSlot: map['time_slot'],
      subjectName: map['subject_name'],
      subjectArea: map['subject_area'],
      level: map['level'],
      axis: map['axis'],
      durationHours: map['duration_hours'] ?? 4,
    );
  }
}
