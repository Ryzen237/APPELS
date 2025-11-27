import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final StudentService _studentService = StudentService();
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _studentService.getAllStudents();
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  Future<void> _addStudent() async {
    final result = await showDialog<Student>(
      context: context,
      builder: (context) => const AddStudentDialog(),
    );

    if (result != null) {
      await _studentService.createStudent(result);
      _loadStudents();
    }
  }

  Future<void> _editStudent(Student student) async {
    final result = await showDialog<Student>(
      context: context,
      builder: (context) => AddStudentDialog(student: student),
    );

    if (result != null) {
      await _studentService.updateStudent(result);
      _loadStudents();
    }
  }

  Future<void> _deleteStudent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _studentService.deleteStudent(id);
      _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addStudent,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      child: ListTile(
                        title: Text(student.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${student.matricule}'),
                            Text('Level ${student.level} (${student.axis})'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editStudent(student),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteStudent(student.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  final Student? student;

  const AddStudentDialog({super.key, this.student});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _levelController = TextEditingController();
  String _selectedAxis = 'GLO';

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _firstnameController.text = widget.student!.firstname;
      _lastnameController.text = widget.student!.lastname;
      _matriculeController.text = widget.student!.matricule;
      _levelController.text = widget.student!.level.toString();
      _selectedAxis = widget.student!.axis;
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _matriculeController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                widget.student == null ? 'Add Student' : 'Edit Student',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _firstnameController,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _matriculeController,
                        decoration: const InputDecoration(
                          labelText: 'Matricule',
                          hintText: 'Ex: 3AG00123 (2xGxxxxx format)'
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter matricule';
                          }
                          // Validate matricule format: 2xGxxxxx (7 characters)
                          final matriculeRegex = RegExp(r'^\d{1}[A-Z]{2}\d{5}$');
                          if (!matriculeRegex.hasMatch(value)) {
                            return 'Matricule must be in format: 2xGxxxxx (e.g., 3AG00123)';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _levelController,
                        decoration: const InputDecoration(labelText: 'Level (3, 4, or 5)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter level';
                          }
                          final level = int.tryParse(value);
                          if (level == null || level < 3 || level > 5) {
                            return 'Level must be 3, 4, or 5';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedAxis,
                        decoration: const InputDecoration(labelText: 'Axis'),
                        items: ['GLO', 'GRT'].map((axis) {
                          return DropdownMenuItem(value: axis, child: Text(axis));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAxis = value ?? 'GLO';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an axis';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final student = Student(
                          id: widget.student?.id,
                          firstname: _firstnameController.text,
                          lastname: _lastnameController.text,
                          matricule: _matriculeController.text,
                          level: int.parse(_levelController.text),
                          axis: _selectedAxis,
                          createdAt: widget.student?.createdAt,
                        );
                        Navigator.of(context).pop(student);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
