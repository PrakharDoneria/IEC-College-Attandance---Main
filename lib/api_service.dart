import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_model.dart';

class ApiService {
  final String baseUrl = 'https://iec-group-of-institutions.onrender.com';

  Future<void> addStudents(List<Student> students) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_students'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(students.map((student) => {
        'name': student.name,
        'class': student.classNumber,
        'roll_number': student.rollNumber,
        'mobile_number': student.mobileNumber,
      }).toList()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add students');
    }
  }

  Future<List<Student>> getStudentsByClass(String classNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/students/$classNumber'));

    if (response.statusCode == 200) {
      final List<dynamic> studentJson = jsonDecode(response.body);
      return studentJson.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> markAttendance(List<Map<String, dynamic>> attendance) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mark_attendance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(attendance),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark attendance');
    }
  }

  Future<String> generateAttendanceExcel(String classNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/generate_excel?classNumber=$classNumber'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['link'];
    } else {
      throw Exception('Failed to generate Excel');
    }
  }
}
