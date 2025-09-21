import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'attendance_screen.dart';
import 'generate_excel_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IEC-CET',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            mainAxisSpacing: 30,
            crossAxisSpacing: 30,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildMenuItem(
                context,
                icon: Icons.person_add_alt_1,
                title: 'Add Student',
                color: Colors.lightGreen.shade400,
                screen: AddStudentScreen(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.assignment_turned_in,
                title: 'Attendance',
                color: Colors.cyan.shade400,
                screen: AttendanceScreen(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.insert_drive_file,
                title: 'Generate Excel',
                color: Colors.amber.shade400,
                screen: GenerateExcelScreen(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.history_edu,
                title: 'History',
                color: Colors.pinkAccent.shade400,
                screen: HistoryScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
        required String title,
        required Color color,
        required Widget screen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: Colors.white),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}