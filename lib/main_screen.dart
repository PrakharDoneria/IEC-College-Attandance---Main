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
        title: Text('Main Menu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildMenuItem(
                context,
                icon: Icons.person_add,
                title: 'Add Student',
                color: Colors.blueAccent,
                screen: AddStudentScreen(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.check_circle,
                title: 'Attendance',
                color: Colors.greenAccent,
                screen: AttendanceScreen(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.file_download,
                title: 'Generate Excel',
                color: Colors.orange,
                screen: GenerateExcelScreen(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.history,
                title: 'History',
                color: Colors.purple,
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
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, size: 40, color: color),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Serif',
                        color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
