import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import './services.dart';
import '../models/models.dart';

class CsvImportService {
  final StudentService _studentService = StudentService();
  final SubjectService _subjectService = SubjectService();
  final UserService _userService = UserService();

  Future<String?> pickCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la sélection du fichier: $e');
    }
  }

  Future<List<List<dynamic>>> _parseCsv(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString(encoding: utf8);
      return const CsvToListConverter().convert(csvString);
    } catch (e) {
      throw Exception('Erreur lors de la lecture du fichier CSV: $e');
    }
  }

  Future<Map<String, dynamic>> importStudents(String filePath) async {
    int successCount = 0;
    int errorCount = 0;
    List<String> errors = [];
    List<Student> successfulImports = [];

    try {
      final csvData = await _parseCsv(filePath);

      if (csvData.isEmpty) {
        return {
          'success': false,
          'message': 'Le fichier CSV est vide',
          'successCount': 0,
          'errorCount': 0,
          'errors': [],
          'students': []
        };
      }

      // Vérifier les en-têtes (ligne 0)
      final headers = csvData[0].map((e) => e.toString().toLowerCase().trim()).toList();
      final expectedHeaders = ['nom', 'prénom', 'matricule', 'niveau', 'axe'];

      bool headersValid = true;
      List<String> missingHeaders = [];

      for (var expectedHeader in expectedHeaders) {
        if (!headers.contains(expectedHeader)) {
          headersValid = false;
          missingHeaders.add(expectedHeader);
        }
      }

      if (!headersValid) {
        return {
          'success': false,
          'message': 'En-têtes manquants ou incorrects. Requis: nom, prénom, matricule, niveau, axe. Manquants: ${missingHeaders.join(", ")}',
          'successCount': 0,
          'errorCount': 0,
          'errors': [],
          'students': []
        };
      }

      // Traiter les données (ligne 1 et suivantes)
      for (int i = 1; i < csvData.length; i++) {
        try {
          final row = csvData[i];
          if (row.length < 5) continue; // Ligne incomplète

          final lastname = row[headers.indexOf('nom')].toString().trim();
          final firstname = row[headers.indexOf('prénom')].toString().trim();
          final matricule = row[headers.indexOf('matricule')].toString().trim();
          final level = int.tryParse(row[headers.indexOf('niveau')].toString().trim());
          final axis = row[headers.indexOf('axe')].toString().trim().toUpperCase();

          // Validation des données
          if (lastname.isEmpty || firstname.isEmpty || matricule.isEmpty) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Données manquantes (nom, prénom ou matricule)');
            continue;
          }

          if (level == null || level < 3 || level > 5) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Niveau invalide (doit être 3, 4 ou 5)');
            continue;
          }

          if (axis != 'GLO' && axis != 'GRT') {
            errorCount++;
            errors.add('Ligne ${i + 1}: Axe invalide (doit être GLO ou GRT)');
            continue;
          }

          // Validation du matricule
          final matriculeRegex = RegExp(r'^\d{2}G\d{5}$');
          if (!matriculeRegex.hasMatch(matricule)) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Format matricule invalide (2xGxxxxx attendu)');
            continue;
          }

          final student = Student(
            firstname: firstname,
            lastname: lastname,
            matricule: matricule,
            level: level,
            axis: axis,
          );

          await _studentService.createStudent(student);
          successfulImports.add(student);
          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Ligne ${i + 1}: Erreur lors de l\'import - $e');
        }
      }

      return {
        'success': errorCount == 0,
        'message': successCount > 0 ? '$successCount étudiant(s) importé(s) avec succès' : 'Aucun étudiant importé',
        'successCount': successCount,
        'errorCount': errorCount,
        'errors': errors,
        'students': successfulImports
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'import: $e',
        'successCount': 0,
        'errorCount': 0,
        'errors': [e.toString()],
        'students': []
      };
    }
  }

  Future<Map<String, dynamic>> importSubjects(String filePath) async {
    int successCount = 0;
    int errorCount = 0;
    List<String> errors = [];
    List<Subject> successfulImports = [];

    try {
      final csvData = await _parseCsv(filePath);

      if (csvData.isEmpty) {
        return {
          'success': false,
          'message': 'Le fichier CSV est vide',
          'successCount': 0,
          'errorCount': 0,
          'errors': [],
          'subjects': []
        };
      }

      // Vérifier les en-têtes
      final headers = csvData[0].map((e) => e.toString().toLowerCase().trim()).toList();
      final expectedHeaders = ['nom de la matière', 'niveau', 'axe'];

      bool headersValid = true;
      List<String> missingHeaders = [];

      for (var expectedHeader in expectedHeaders) {
        if (!headers.contains(expectedHeader)) {
          headersValid = false;
          missingHeaders.add(expectedHeader);
        }
      }

      if (!headersValid) {
        return {
          'success': false,
          'message': 'En-têtes manquants ou incorrects. Requis: nom de la matière, niveau, axe. Manquants: ${missingHeaders.join(", ")}',
          'successCount': 0,
          'errorCount': 0,
          'errors': [],
          'subjects': []
        };
      }

      // Traiter les données
      for (int i = 1; i < csvData.length; i++) {
        try {
          final row = csvData[i];
          if (row.length < 3) continue;

          final name = row[headers.indexOf('nom de la matière')].toString().trim();
          final level = int.tryParse(row[headers.indexOf('niveau')].toString().trim());
          final axis = row[headers.indexOf('axe')].toString().trim().toUpperCase();

          if (name.isEmpty) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Nom de matière requis');
            continue;
          }

          if (level == null || level < 3 || level > 5) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Niveau invalide (doit être 3, 4 ou 5)');
            continue;
          }

          if (axis != 'GLO' && axis != 'GRT') {
            errorCount++;
            errors.add('Ligne ${i + 1}: Axe invalide (doit être GLO ou GRT)');
            continue;
          }

          final subject = Subject(
            name: name,
            subjectArea: name, // Même valeur pour les deux
            level: level,
            axis: axis,
          );

          await _subjectService.createSubject(subject);
          successfulImports.add(subject);
          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Ligne ${i + 1}: Erreur lors de l\'import - $e');
        }
      }

      return {
        'success': errorCount == 0,
        'message': successCount > 0 ? '$successCount matière(s) importée(s) avec succès' : 'Aucune matière importée',
        'successCount': successCount,
        'errorCount': errorCount,
        'errors': errors,
        'subjects': successfulImports
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'import: $e',
        'successCount': 0,
        'errorCount': 0,
        'errors': [e.toString()],
        'subjects': []
      };
    }
  }

  Future<Map<String, dynamic>> importTeachers(String filePath) async {
    int successCount = 0;
    int errorCount = 0;
    List<String> errors = [];
    List<User> successfulImports = [];

    try {
      final csvData = await _parseCsv(filePath);

      if (csvData.isEmpty) {
        return {
          'success': false,
          'message': 'Le fichier CSV est vide',
          'successCount': 0,
          'errorCount': 0,
          'errors': [],
          'teachers': []
        };
      }

      // Vérifier les en-têtes
      final headers = csvData[0].map((e) => e.toString().toLowerCase().trim()).toList();
      final expectedHeaders = ['email', 'mot de passe', 'nom affiché'];

      bool headersValid = true;
      List<String> missingHeaders = [];

      for (var expectedHeader in expectedHeaders) {
        if (!headers.contains(expectedHeader)) {
          headersValid = false;
          missingHeaders.add(expectedHeader);
        }
      }

      if (!headersValid) {
        return {
          'success': false,
          'message': 'En-têtes manquants ou incorrects. Requis: email, mot de passe, nom affiché. Manquants: ${missingHeaders.join(", ")}',
          'successCount': 0,
          'errorCount': 0,
          'errors': [],
          'teachers': []
        };
      }

      // Traiter les données
      for (int i = 1; i < csvData.length; i++) {
        try {
          final row = csvData[i];
          if (row.length < 3) continue;

          final email = row[headers.indexOf('email')].toString().trim();
          final password = row[headers.indexOf('mot de passe')].toString().trim();
          final displayName = row[headers.indexOf('nom affiché')].toString().trim();

          if (email.isEmpty || password.isEmpty) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Email et mot de passe requis');
            continue;
          }

          if (!email.contains('@')) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Format email invalide');
            continue;
          }

          // Vérifier si l'email existe déjà
          final existingUser = await _userService.getAllUsers();
          final emailExists = existingUser.any((user) => user.email == email);

          if (emailExists) {
            errorCount++;
            errors.add('Ligne ${i + 1}: Email déjà utilisé');
            continue;
          }

          final user = User(
            email: email,
            passwordHash: password, // Sera hashé par UserService
            role: 'teacher',
            displayName: displayName.isEmpty ? email.split('@')[0] : displayName,
          );

          await _userService.createUser(user);
          successfulImports.add(user);
          successCount++;
        } catch (e) {
          errorCount++;
          errors.add('Ligne ${i + 1}: Erreur lors de l\'import - $e');
        }
      }

      return {
        'success': errorCount == 0,
        'message': successCount > 0 ? '$successCount enseignant(s) importé(s) avec succès' : 'Aucun enseignant importé',
        'successCount': successCount,
        'errorCount': errorCount,
        'errors': errors,
        'teachers': successfulImports
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'import: $e',
        'successCount': 0,
        'errorCount': 0,
        'errors': [e.toString()],
        'teachers': []
      };
    }
  }

  Future<void> generateSampleCsv(String type) async {
    try {
      String csvContent = '';
      String fileName = '';

      switch (type) {
        case 'students':
          fileName = 'etudiants_modele.csv';
          csvContent = '''nom,prénom,matricule,niveau,axe
Dupont,Jean,21G12345,3,GLO
Martin,Marie,22G67890,4,GRT
Lefebvre,Paul,23G11111,5,GLO
Dubois,Sophie,24G22222,3,GRT''';
          break;

        case 'subjects':
          fileName = 'matieres_modele.csv';
          csvContent = '''nom de la matière,niveau,axe
Mathématiques,3,GLO
Physique,4,GLO
Informatique,5,GRT
Chimie,4,GRT''';
          break;

        case 'teachers':
          fileName = 'enseignants_modele.csv';
          csvContent = '''email,mot de passe,nom affiché
prof1@university.edu,prof123,Professeur Dupont
prof2@university.edu,prof456,Madame Martin
prof3@university.edu,prof789,Monsieur Lefebvre''';
          break;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent, encoding: utf8);

      // TODO: Ici on pourrait partager le fichier avec share_plus
      // ou afficher un message à l'utilisateur pour l'emplacement
    } catch (e) {
      throw Exception('Erreur lors de la génération du fichier modèle: $e');
    }
  }
}
