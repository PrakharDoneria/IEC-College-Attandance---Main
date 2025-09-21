import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'student_model.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Student> students = [];
  Map<String, String> attendanceStatus = {};
  String classNumber = '';
  String subjectCode = '';
  bool isLoading = false;
  final String baseUrl = 'https://iec-attendance-nodejs.onrender.com';
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  Future<void> fetchStudents() async {
    if (_classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a class number')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/students/${_classController.text}'));
      if (response.statusCode == 200) {
        final List<dynamic> studentJson = jsonDecode(response.body);
        students = studentJson.map((json) {
          return Student(
            name: json['Name'] ?? '',
            classNumber: json['Class_Number'] ?? '',
            rollNumber: json['Roll_Number'] ?? '',
            mobileNumber: json['Mobile_Number'] ?? '',
          );
        }).toList();
        students.sort((a, b) => a.name.compareTo(b.name));
        for (var student in students) {
          attendanceStatus[student.rollNumber] = "Absent";
        }
        setState(() {});
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load students')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitAttendance() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter subject code')),
      );
      return;
    }
    List<Map<String, dynamic>> attendanceData = [];
    for (var student in students) {
      attendanceData.add({
        'Roll_Number': student.rollNumber,
        'Name': student.name,
        'Status': attendanceStatus[student.rollNumber] ?? "Absent",
        'Subject_Code': _subjectController.text,
        'Class_Number': _classController.text,
      });
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/faculty/mark_attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(attendanceData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted!')),
        );
      } else {
        throw Exception('Failed to submit attendance');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance')),
      );
    }
  }

  void askForSubjectCode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Subject Code', style: TextStyle(color: Colors.deepPurple)),
          content: TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Subject Code',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                submitAttendance();
              },
              child: Text('Submit', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.purple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Class Number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _classController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Class Number',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  prefixIcon: Icon(Icons.school, color: Colors.white70),
                ),
                onChanged: (value) {
                  classNumber = value;
                },
              ),
              SizedBox(height: 20),
              _buildModernButton(
                onPressed: fetchStudents,
                text: 'Load Students',
              ),
              SizedBox(height: 20),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          students[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Roll No: ${students[index].rollNumber}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        trailing: ToggleButtons(
                          children: [
                            Text('  P  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('  A  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                          isSelected: [
                            attendanceStatus[students[index].rollNumber] == "Present",
                            attendanceStatus[students[index].rollNumber] == "Absent",
                          ],
                          onPressed: (int selectedIndex) {
                            setState(() {
                              attendanceStatus[students[index].rollNumber] =
                              selectedIndex == 0 ? "Present" : "Absent";
                            });
                          },
                          color: Colors.white,
                          selectedColor: Colors.white,
                          fillColor: attendanceStatus[students[index].rollNumber] == "Present" ? Colors.green : Colors.red,
                          borderColor: Colors.white70,
                          selectedBorderColor: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              if (students.isNotEmpty)
                _buildModernButton(
                  onPressed: askForSubjectCode,
                  text: 'Submit Attendance',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton({required VoidCallback onPressed, required String text}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}