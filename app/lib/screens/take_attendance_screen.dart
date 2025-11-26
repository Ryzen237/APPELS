import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../providers/app_provider.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final Subject subject;

  const TakeAttendanceScreen({super.key, required this.subject});

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final StudentService _studentService = StudentService();
  final AttendanceService _attendanceService = AttendanceService();
  List<Student> _students = [];
  Map<int, bool> _attendanceMap = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _studentService.getAllStudents();
    setState(() {
      _students = students;
      _attendanceMap = {for (var student in students) student.id!: true};
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAttendance() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final teacherId = appProvider.currentUser!.id!;

    // Create attendance record
    final attendance = Attendance(
      subjectId: widget.subject.id!,
      teacherId: teacherId,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    final attendanceId = await _attendanceService.createAttendance(attendance);

    // Create attendance items
    final attendanceItems = _students.map((student) {
      return AttendanceItem(
        attendanceId: attendanceId,
        studentId: student.id!,
        status: _attendanceMap[student.id!]! ? 'present' : 'absent',
      );
    }).toList();

    await _attendanceService.addAttendanceItems(attendanceId, attendanceItems);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Attendance - ${widget.subject.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text('Date: '),
                      TextButton(
                        onPressed: _selectDate,
                        child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        child: CheckboxListTile(
                          title: Text(student.fullName),
                          value: _attendanceMap[student.id!],
                          onChanged: (bool? value) {
                            setState(() {
                              _attendanceMap[student.id!] = value ?? false;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
