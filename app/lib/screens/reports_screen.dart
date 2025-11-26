import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../services/services.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final SubjectService _subjectService = SubjectService();
  final AttendanceService _attendanceService = AttendanceService();
  List<Subject> _subjects = [];
  List<Map<String, dynamic>> _reportData = [];
  bool _isLoading = true;
  Subject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _subjectService.getAllSubjects();
    setState(() {
      _subjects = subjects;
      _isLoading = false;
    });
  }

  Future<void> _loadReport() async {
    if (_selectedSubject == null) return;

    setState(() => _isLoading = true);
    final reportData = await _attendanceService.getAttendanceReportBySubject(_selectedSubject!.id!);
    setState(() {
      _reportData = reportData;
      _isLoading = false;
    });
  }

  Future<void> _exportToCSV() async {
    if (_reportData.isEmpty || _selectedSubject == null) return;

    // Prepare CSV data
    List<List<String>> csvData = [
      ['Student Name', 'Total Sessions', 'Present Count', 'Attendance Rate (%)'],
      ..._reportData.map((data) => [
        '${data['firstname']} ${data['lastname']}',
        data['total_sessions'].toString(),
        data['present_count'].toString(),
        '${data['attendance_rate']}%',
      ]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/attendance_report_${_selectedSubject!.name}.csv');
    await file.writeAsString(csv);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Attendance Report for ${_selectedSubject!.name}');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report exported successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Select Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: _subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name),
                      );
                    }).toList(),
                    onChanged: (Subject? value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                      _loadReport();
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedSubject != null ? _loadReport : null,
                          child: const Text('Generate Report'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _reportData.isNotEmpty ? _exportToCSV : null,
                          child: const Text('Export CSV'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _reportData.isEmpty
                        ? const Center(child: Text('No data available'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Student')),
                                DataColumn(label: Text('Total Sessions')),
                                DataColumn(label: Text('Present')),
                                DataColumn(label: Text('Attendance %')),
                              ],
                              rows: _reportData.map((data) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${data['firstname']} ${data['lastname']}')),
                                    DataCell(Text(data['total_sessions'].toString())),
                                    DataCell(Text(data['present_count'].toString())),
                                    DataCell(Text('${data['attendance_rate']}%')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
