import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../widgets/csv_import_dialog.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final UserService _userService = UserService();
  final SubjectService _subjectService = SubjectService();
  List<User> _teachers = [];
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final teachers = await _userService.getUsersByRole('teacher');
    final subjects = await _subjectService.getAllSubjects();
    setState(() {
      _teachers = teachers;
      _subjects = subjects;
      _isLoading = false;
    });
  }

  Future<void> _addTeacher() async {
    final result = await showDialog<User>(
      context: context,
      builder: (context) => const AddTeacherDialog(),
    );

    if (result != null) {
      await _userService.createUser(result);
      _loadData();
    }
  }

  Future<void> _editTeacher(User teacher) async {
    final result = await showDialog<User>(
      context: context,
      builder: (context) => AddTeacherDialog(teacher: teacher),
    );

    if (result != null) {
      await _userService.updateUser(result);
      _loadData();
    }
  }

  Future<void> _deleteTeacher(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'Enseignant'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet enseignant ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _userService.deleteUser(id);
      _loadData();
    }
  }

  Future<void> _assignSubjects(User teacher) async {
    final result = await showDialog<List<int>>(
      context: context,
      builder: (context) => AssignSubjectsDialog(
        teacher: teacher,
        allSubjects: _subjects,
        subjectService: _subjectService,
      ),
    );

    if (result != null) {
      // Handle subject assignments
      _loadData();
    }
  }

  void _importTeachers() {
    showDialog(
      context: context,
      builder: (context) => const ImportDialog(type: 'teachers'),
    ).then((result) {
      if (result != null) {
        _loadData(); // Recharger la liste après import
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Enseignants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Importer depuis CSV',
            onPressed: _importTeachers,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un enseignant',
            onPressed: _addTeacher,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teachers.isEmpty
              ? const Center(child: Text('Aucun enseignant trouvé'))
              : ListView.builder(
                  itemCount: _teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = _teachers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(teacher.displayName ?? teacher.email),
                        subtitle: Text(teacher.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.book),
                              onPressed: () => _assignSubjects(teacher),
                              tooltip: 'Assigner des matières',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Modifier',
                              onPressed: () => _editTeacher(teacher),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Supprimer',
                              color: Colors.red,
                              onPressed: () => _deleteTeacher(teacher.id!),
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

class AddTeacherDialog extends StatefulWidget {
  final User? teacher;

  const AddTeacherDialog({super.key, this.teacher});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _emailController.text = widget.teacher!.email;
      _displayNameController.text = widget.teacher!.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.teacher == null ? 'Ajouter un Enseignant' : 'Modifier un Enseignant'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir l\'email';
                }
                return null;
              },
            ),
            if (widget.teacher == null)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le mot de passe';
                  }
                  return null;
                },
              ),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Nom affiché'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final teacher = User(
                id: widget.teacher?.id,
                email: _emailController.text,
                passwordHash: widget.teacher?.passwordHash ?? _passwordController.text,
                role: 'teacher',
                displayName: _displayNameController.text.isEmpty ? null : _displayNameController.text,
                createdAt: widget.teacher?.createdAt,
              );
              Navigator.of(context).pop(teacher);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class AssignSubjectsDialog extends StatefulWidget {
  final User teacher;
  final List<Subject> allSubjects;
  final SubjectService subjectService;

  const AssignSubjectsDialog({
    super.key,
    required this.teacher,
    required this.allSubjects,
    required this.subjectService,
  });

  @override
  State<AssignSubjectsDialog> createState() => _AssignSubjectsDialogState();
}

class _AssignSubjectsDialogState extends State<AssignSubjectsDialog> {
  List<int> _assignedSubjectIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedSubjects();
  }

  Future<void> _loadAssignedSubjects() async {
    final assignments = await widget.subjectService.getAllAssignments();
    setState(() {
      _assignedSubjectIds = assignments
          .where((a) => a.teacherId == widget.teacher.id)
          .map((a) => a.subjectId)
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assigner des Matières à ${widget.teacher.displayName ?? widget.teacher.email}'),
      content: _isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allSubjects.length,
                itemBuilder: (context, index) {
                  final subject = widget.allSubjects[index];
                  final isAssigned = _assignedSubjectIds.contains(subject.id);
                  return CheckboxListTile(
                    title: Text(subject.name),
                    value: isAssigned,
                    onChanged: (bool? value) async {
                      if (value == true) {
                        await widget.subjectService.assignSubjectToTeacher(subject.id!, widget.teacher.id!);
                        setState(() {
                          _assignedSubjectIds.add(subject.id!);
                        });
                      } else {
                        await widget.subjectService.removeAssignment(subject.id!, widget.teacher.id!);
                        setState(() {
                          _assignedSubjectIds.remove(subject.id!);
                        });
                      }
                    },
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
