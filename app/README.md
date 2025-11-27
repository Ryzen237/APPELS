# Attendance Management System

A comprehensive Flutter application for managing student attendance across educational institutions.

## Features

- **Multi-Role Authentication**: Teacher, Department Head (CDD), and Director roles
- **Student Management**: Add, edit, and manage student records with matricule system
- **Subject Management**: Create and assign subjects with level and axis grouping
- **Attendance Tracking**: Real-time attendance taking and monitoring
- **Reports & Analytics**: Comprehensive reports and attendance statistics
- **Teacher Assignment**: Automatic subject assignment display

## Getting Started

### Prerequisites
- Flutter SDK (v3.7.0 or higher)
- Dart SDK
- Android Studio / Visual Studio Code

### Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd appels/app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create app icon (optional):
   ```bash
   # Create assets/icons/app_icon.png (1024x1024px)
   # with blue circle gradient and school icon design
   flutter pub run flutter_launcher_icons
   ```

4. Run the application:
   ```bash
   flutter run --debug
   ```

## Default Accounts

### Department Head (CDD)
- **Email**: `cdd@university.edu`
- **Password**: `cdd123`
- **Display Name**: Dr MAKA MAKA Ebenezer
- **Permissions**: Manage students, teachers, subjects

### Director
- **Email**: `director@university.edu`
- **Password**: `director123`
- **Display Name**: Pr Ruben MOUANGUE
- **Permissions**: View institution-wide reports

### Teacher
- **Email**: `teacher@university.edu`
- **Password**: `teacher123`
- **Display Name**: John Smith
- **Permissions**: Take attendance, view assigned subjects

## App Features

### Student Registration
- **Required Fields**:
  - First Name & Last Name
  - Matricule (format: 2xGxxxxx, e.g., 3AG00123)
  - Level (3, 4, or 5)
  - Axis (GLO or GRT)

### Subject Creation
- **Simplified Form**:
  - Subject Name
  - Level (3, 4, or 5)
  - Axis (GLO or GRT)

### Teacher Dashboard
- **Assigned Subjects**: Shows all subjects assigned with level and axis
- **Attendance Taking**: Take attendance for assigned classes
- **History**: View past attendance sessions

## Technical Details

### Database Schema
- **Students**: matricule, level, axis with unique constraints
- **Subjects**: name, level, axis grouping
- **Attendance**: Session-based tracking with automated analytics

### Architecture
- **Provider Pattern**: For state management
- **SQLite**: Local database for offline functionality
- **RESTful API Ready**: Expandable to web service

## Building for Release

### Android APK
```bash
flutter build apk --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
