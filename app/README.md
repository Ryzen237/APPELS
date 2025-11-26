# Attendance Management System

A comprehensive Flutter-based attendance management system designed for educational institutions. This application allows different user roles to efficiently manage student attendance, subjects, and reporting.

## Features

### Role-Based Access Control

- **CdD (Department Head)**: Manage students, teachers, subjects, semesters, and view comprehensive reports
- **Teacher**: Take attendance for assigned subjects and view student attendance
- **Director**: View overall institution reports and analytics

### Core Functionality

- Student management (add, edit, delete students)
- Teacher management and assignment to subjects
- Subject and semester management
- Session scheduling (daily attendance records)
- Real-time attendance tracking
- Comprehensive reporting with charts and analytics
- CSV export for attendance records
- Secure authentication with password hashing

## Technology Stack

- **Framework**: Flutter (SDK ^3.7.0)
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Charts**: FL Chart
- **Secure Storage**: Flutter Secure Storage
- **Password Hashing**: BCrypt
- **File Operations**: Share Plus

## Installation & Setup

1. Ensure you have Flutter SDK installed
2. Clone the repository
3. Navigate to the project directory
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` or `flutter run --debug` for development

### Default Accounts

The application comes with three pre-configured accounts for testing different user roles:

**Teacher Account:**

- **Email**: teacher@university.edu
- **Password**: teacher123
- **Display Name**: John Smith
- **Access Level**: Can take attendance for assigned subjects and view student attendance

**CdD (Department Head) Account:**

- **Email**: cdd@university.edu
- **Password**: cdd123
- **Display Name**: Dr MAKA MAKA Ebenezer
- **Access Level**: Can manage students, teachers, subjects, semesters, and view comprehensive reports

**Director Account:**

- **Email**: director@university.edu
- **Password**: director123
- **Display Name**: Pr Ruben MOUANGUE
- **Access Level**: Can view overall institution reports and analytics

## Project Structure

```dart
lib/
├── database/
│   └── database_helper.dart          # SQLite database configuration
├── models/                          # Data models
│   ├── user.dart                    # User model (Teacher, CdD, Director)
│   ├── student.dart                 # Student model
│   ├── subject.dart                 # Subject model
│   ├── semester.dart                # Semester model
│   ├── session.dart                 # Session model
│   ├── attendance.dart              # Attendance record model
│   └── attendance_item.dart         # Individual attendance items
├── providers/
│   └── app_provider.dart            # State management
├── screens/                         # UI Screens
│   ├── login_screen.dart            # Authentication
│   ├── cdd_dashboard.dart           # Department Head dashboard
│   ├── teacher_dashboard.dart       # Teacher dashboard
│   ├── director_dashboard.dart      # Director dashboard
│   ├── manage_students_screen.dart  # Student management
│   ├── manage_subjects_screen.dart  # Subject management
│   ├── manage_teachers_screen.dart  # Teacher management
│   ├── take_attendance_screen.dart  # Attendance recording
│   └── reports_screen.dart          # Analytics and reports
├── services/                        # Business logic and database operations
└── widgets/                         # Reusable UI components
    └── app_logo.dart                # Application logo widget
```

## Database Schema

The application uses SQLite with the following tables:

- `users` - Store user accounts (teachers, CdD, directors)
- `semester` - Academic semesters
- `subjects` - Course subjects
- `students` - Student information
- `assignments` - Teacher-subject assignments
- `sessions` - Attendance sessions for subjects
- `attendance` - Attendance records
- `attendance_items` - Individual student attendance entries

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](<https://docs.flutter.dev/get-started/codelab>)
- [Cookbook: Useful Flutter samples](<https://docs.flutter.dev/cookbook>)

For help getting started with Flutter development, view the
[online documentation](<https://docs.flutter.dev/>), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
