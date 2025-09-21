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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _rollController = TextEditingController();
  final _mobileController = TextEditingController();

  void addStudent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Student student = Student(
        name: _nameController.text,
        classNumber: _classController.text,
        rollNumber: _rollController.text,
        mobileNumber: _mobileController.text,
      );

      await apiService.addStudents([student]);
      setState(() {
        students.add(student);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student added successfully!')),
      );
      _clearFields();
    }
  }

  void _clearFields() {
    _nameController.clear();
    _classController.clear();
    _rollController.clear();
    _mobileController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _rollController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Student',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Student Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              _buildTextField('Full Name', _nameController, false),
              SizedBox(height: 24),
              _buildTextField('Class Number', _classController, false),
              SizedBox(height: 24),
              _buildTextField('Roll Number', _rollController, false),
              SizedBox(height: 24),
              _buildTextField('Mobile Number', _mobileController, true),
              SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isMobile) {
    return TextFormField(
      controller: controller,
      keyboardType: isMobile ? TextInputType.phone : TextInputType.text,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(_getIconForLabel(label), color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Full Name':
        return Icons.person;
      case 'Class Number':
        return Icons.school;
      case 'Roll Number':
        return Icons.format_list_numbered;
      case 'Mobile Number':
        return Icons.phone;
      default:
        return Icons.info;
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: addStudent,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 8,
      ),
      child: Text(
        'Add Student',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}