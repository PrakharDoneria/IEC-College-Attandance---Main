import 'package:flutter/material.dart';
import 'api_service.dart';
import 'student_model.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final ApiService apiService = ApiService();
  List<Student> students = [];
  String? name;
  String? classNumber;
  String? rollNumber;
  String? mobileNumber;

  void addStudent() async {
    if (name == null ||
        classNumber == null ||
        rollNumber == null ||
        mobileNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    Student student = Student(
      name: name!,
      classNumber: classNumber!,
      rollNumber: rollNumber!,
      mobileNumber: mobileNumber!,
    );

    await apiService.addStudents([student]);
    setState(() {
      students.add(student);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Student added!')));
    _clearFields();
  }

  void _clearFields() {
    name = null;
    classNumber = null;
    rollNumber = null;
    mobileNumber = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Student Details',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange),
            ),
            SizedBox(height: 16),
            _buildTextField('Name', (value) => name = value),
            _buildTextField('Class Number', (value) => classNumber = value),
            _buildTextField('Roll Number', (value) => rollNumber = value),
            _buildTextField('Mobile Number', (value) => mobileNumber = value),
            SizedBox(height: 20),
            Center(child: _buildSubmitButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepOrange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange),
          ),
          filled: true,
          fillColor: Colors.yellow[100],
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.orangeAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: addStudent,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Text(
          'Submit',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }
}
