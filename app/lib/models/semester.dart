class Semester {
  int? id;
  String name;
  String? startDate;
  String? endDate;

  Semester({
    this.id,
    required this.name,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      id: map['id'],
      name: map['name'],
      startDate: map['start_date'],
      endDate: map['end_date'],
    );
  }
}
