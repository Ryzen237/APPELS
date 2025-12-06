import 'package:flutter/material.dart';
import '../services/services.dart';

class ImportDialog extends StatefulWidget {
  final String type; // 'students', 'subjects', 'teachers'

  const ImportDialog({super.key, required this.type});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final CsvImportService _csvImportService = CsvImportService();
  bool _isImporting = false;
  String? _importFilePath;
  Map<String, dynamic>? _importResult;

  String _getDialogTitle() {
    switch (widget.type) {
      case 'students':
        return 'Importer des étudiants depuis CSV';
      case 'subjects':
        return 'Importer des matières depuis CSV';
      case 'teachers':
        return 'Importer des enseignants depuis CSV';
      default:
        return 'Importer depuis CSV';
    }
  }

  String _getExpectedHeaders() {
    switch (widget.type) {
      case 'students':
        return 'nom, prénom, matricule, niveau, axe';
      case 'subjects':
        return 'nom de la matière, niveau, axe';
      case 'teachers':
        return 'email, mot de passe, nom affiché';
      default:
        return '';
    }
  }

  Future<void> _pickFile() async {
    try {
      final filePath = await _csvImportService.pickCsvFile();
      if (filePath != null) {
        setState(() {
          _importFilePath = filePath;
          _importResult = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la sélection du fichier: $e');
    }
  }

  Future<void> _generateSample() async {
    try {
      await _csvImportService.generateSampleCsv(widget.type);
      _showInfoDialog('Fichier modèle généré dans le dossier Documents de l\'app');
    } catch (e) {
      _showErrorDialog('Erreur lors de la génération du modèle: $e');
    }
  }

  Future<void> _performImport() async {
    if (_importFilePath == null) {
      _showErrorDialog('Veuillez d\'abord sélectionner un fichier CSV');
      return;
    }

    setState(() => _isImporting = true);

    try {
      Map<String, dynamic> result;
      switch (widget.type) {
        case 'students':
          result = await _csvImportService.importStudents(_importFilePath!);
          break;
        case 'subjects':
          result = await _csvImportService.importSubjects(_importFilePath!);
          break;
        case 'teachers':
          result = await _csvImportService.importTeachers(_importFilePath!);
          break;
        default:
          throw Exception('Type d\'import non supporté');
      }

      setState(() => _importResult = result);

      if (result['success'] == true) {
        _showSuccessDialog(result['message']);
      } else {
        _showResultDialog(result);
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'import: $e');
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialog de succès
              Navigator.of(context).pop(); // Ferme le dialog d'import
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['success'] ? 'Import réussi' : 'Import partiellement réussi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(result['message']),
              const SizedBox(height: 8),
              Text('Succès: ${result['successCount']}'),
              Text('Erreurs: ${result['errorCount']}'),
              if (result['errors'] != null && (result['errors'] as List).isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Détails des erreurs:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: (result['errors'] as List).length,
                    itemBuilder: (context, index) => Text(
                      '• ${(result['errors'] as List)[index]}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialog de résultats
              Navigator.of(context).pop(); // Ferme le dialog d'import
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getDialogTitle(),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // Explication du format attendu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Format CSV attendu:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('En-têtes: ${_getExpectedHeaders()}'),
                    const SizedBox(height: 8),
                    const Text(
                        'Note: Assurez-vous que les en-têtes sont exactement comme indiqué ci-dessus.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.file_open),
                      label: const Text('Sélectionner CSV'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generateSample,
                      icon: const Icon(Icons.download),
                      label: const Text('Modèle CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              if (_importFilePath != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fichier sélectionné: ${_importFilePath!.split('/').last}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Bouton d'import
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _importFilePath != null && !_isImporting ? _performImport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isImporting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Importer les données'),
                ),
              ),

              const SizedBox(height: 12),

              // Bouton Annuler
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
