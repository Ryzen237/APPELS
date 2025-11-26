import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Subject> _subjects = [];
  bool _isLoading = true;

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

  Future<void> _addSubject() async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (context) => const AddSubjectDialog(),
    );

    if (result != null) {
      await _subjectService.createSubject(result);
      _loadSubjects();
    }
  }

  Future<void> _editSubject(Subject subject) async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (context) => AddSubjectDialog(subject: subject),
    );

    if (result != null) {
      await _subjectService.updateSubject(result);
      _loadSubjects();
    }
  }

  Future<void> _deleteSubject(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
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
      await _subjectService.deleteSubject(id);
      _loadSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSubject,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(child: Text('No subjects found'))
              : ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Card(
                      child: ListTile(
                        title: Text(subject.name),
                        subtitle: Text('Sessions per week: ${subject.sessionsPerWeek}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editSubject(subject),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteSubject(subject.id!),
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

class AddSubjectDialog extends StatefulWidget {
  final Subject? subject;

  const AddSubjectDialog({super.key, this.subject});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectAreaController = TextEditingController();
  final _levelController = TextEditingController();
  final _axisController = TextEditingController();
  final _sessionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _subjectAreaController.text = widget.subject!.subjectArea;
      _levelController.text = widget.subject!.level.toString();
      _axisController.text = widget.subject!.axis;
      _sessionsController.text = widget.subject!.sessionsPerWeek.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectAreaController.dispose();
    _levelController.dispose();
    _axisController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter subject name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _subjectAreaController,
              decoration: const InputDecoration(labelText: 'Subject Area'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter subject area';
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
              value: _axisController.text.isNotEmpty ? _axisController.text : null,
              decoration: const InputDecoration(labelText: 'Axis'),
              items: ['GLO', 'GRT'].map((axis) {
                return DropdownMenuItem(value: axis, child: Text(axis));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _axisController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an axis';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _sessionsController,
              decoration: const InputDecoration(labelText: 'Sessions per Week'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sessions per week';
                }
                final num = int.tryParse(value);
                if (num == null || num <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final subject = Subject(
                id: widget.subject?.id,
                name: _nameController.text,
                subjectArea: _subjectAreaController.text,
                level: int.parse(_levelController.text),
                axis: _axisController.text,
                sessionsPerWeek: int.parse(_sessionsController.text),
              );
              Navigator.of(context).pop(subject);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
