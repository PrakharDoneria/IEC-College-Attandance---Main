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
  final String baseUrl = 'https://iec-group-of-institutions.onrender.com';

  Future<void> fetchStudents() async {
    if (classNumber.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a class number')));
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/students/$classNumber'));
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
        students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
        for (var student in students) {
          attendanceStatus[student.rollNumber] = "Absent";
        }
        setState(() {});
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load students')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitAttendance() async {
    if (subjectCode.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter subject code')));
      return;
    }
    List<Map<String, dynamic>> attendanceData = [];
    for (var student in students) {
      attendanceData.add({
        'Roll_Number': student.rollNumber,
        'Name': student.name,
        'Status': attendanceStatus[student.rollNumber] ?? "Absent",
        'Subject_Code': subjectCode,
        'Class_Number': classNumber,
      });
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mark_attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(attendanceData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Attendance submitted!')));
      } else {
        throw Exception('Failed to submit attendance');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to submit attendance')));
    }
  }

  void askForSubjectCode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Subject Code',
              style: TextStyle(color: Colors.deepOrange)),
          content: TextField(
            onChanged: (value) {
              setState(() {
                subjectCode = value;
              });
            },
            decoration: InputDecoration(hintText: 'Subject Code'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                submitAttendance();
              },
              child: Text('Submit'),
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
        title: Text('Attendance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Class Number',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange)),
            TextField(
              decoration: InputDecoration(
                hintText: 'Class Number',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.yellow[100],
              ),
              onChanged: (value) {
                setState(() {
                  classNumber = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildIndianStyledButton(
              onPressed: fetchStudents,
              text: 'Load Students',
            ),
            SizedBox(height: 20),
            if (isLoading) Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(students[index].name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Roll No: ${students[index].rollNumber}',
                              style: TextStyle(color: Colors.black)),
                          Text('Mobile No: ${students[index].mobileNumber}',
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      trailing: ToggleButtons(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          Icon(Icons.cancel, color: Colors.red),
                        ],
                        isSelected: [
                          attendanceStatus[students[index].rollNumber] ==
                              "Present",
                          attendanceStatus[students[index].rollNumber] ==
                              "Absent",
                        ],
                        onPressed: (int selectedIndex) {
                          setState(() {
                            attendanceStatus[students[index].rollNumber] =
                                selectedIndex == 0 ? "Present" : "Absent";
                          });
                        },
                        color: Colors.grey,
                        selectedColor: Colors.white,
                        fillColor: Colors.deepOrange,
                        borderColor: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (students.isNotEmpty)
              _buildIndianStyledButton(
                onPressed: askForSubjectCode,
                text: 'Submit Attendance',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndianStyledButton(
      {required VoidCallback onPressed, required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Serif',
          ),
        ),
      ),
    );
  }
}
