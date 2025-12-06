import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../widgets/csv_import_dialog.dart';

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
        title: const Text('Supprimer la Matière'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette matière ?'),
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
      await _subjectService.deleteSubject(id);
      _loadSubjects();
    }
  }

  void _importSubjects() {
    showDialog(
      context: context,
      builder: (context) => const ImportDialog(type: 'subjects'),
    ).then((result) {
      if (result != null) {
        _loadSubjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Matières'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Importer depuis CSV',
            onPressed: _importSubjects,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une matière',
            onPressed: _addSubject,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(child: Text('Aucune matière trouvée'))
              : ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(subject.name),
                        subtitle: Text('Niveau ${subject.level} (${subject.axis})'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Modifier',
                              onPressed: () => _editSubject(subject),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Supprimer',
                              color: Colors.red,
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
  final _levelController = TextEditingController();
  String _selectedAxis = 'GLO';

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _levelController.text = widget.subject!.level.toString();
      _selectedAxis = widget.subject!.axis;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.subject == null ? 'Ajouter une Matière' : 'Modifier une Matière'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom de la Matière'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir le nom de la matière';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Niveau (3, 4 ou 5)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir le niveau';
                }
                final level = int.tryParse(value);
                if (level == null || level < 3 || level > 5) {
                  return 'Le niveau doit être 3, 4 ou 5';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedAxis,
              decoration: const InputDecoration(labelText: 'Filière'),
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
                  return 'Veuillez sélectionner une filière';
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
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final subject = Subject(
                id: widget.subject?.id,
                name: _nameController.text,
                subjectArea: _nameController.text, // Subject area equals subject name
                level: int.parse(_levelController.text),
                axis: _selectedAxis,
                sessionsPerWeek: 2, // Default value for sessions per week
              );
              Navigator.of(context).pop(subject);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
