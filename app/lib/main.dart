import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/cdd_dashboard.dart';
import 'screens/director_dashboard.dart';
import 'screens/manage_students_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/teacher-dashboard': (context) => const TeacherDashboard(),
        '/cdd-dashboard': (context) => const CddDashboard(),
        '/director-dashboard': (context) => const DirectorDashboard(),
        '/manage-students': (context) => const ManageStudentsScreen(),
        '/overall-reports': (context) => const ReportsScreen(),
        '/student-reports': (context) => const ReportsScreen(),
        '/subject-reports': (context) => const ReportsScreen(),
        '/teacher-reports': (context) => const ReportsScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (!appProvider.isLoggedIn) {
          return const LoginScreen();
        }

        switch (appProvider.userRole) {
          case 'teacher':
            return const TeacherDashboard();
          case 'cdd':
            return const CddDashboard();
          case 'director':
            return const DirectorDashboard();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
