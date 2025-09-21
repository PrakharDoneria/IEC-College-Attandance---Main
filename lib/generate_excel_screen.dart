import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class GenerateExcelScreen extends StatefulWidget {
  @override
  _GenerateExcelScreenState createState() => _GenerateExcelScreenState();
}

class _GenerateExcelScreenState extends State<GenerateExcelScreen> {
  String classNumber = '';
  String excelLink = '';
  bool isLoading = false;
  final TextEditingController _classController = TextEditingController();

  Future<void> generateExcel() async {
    if (_classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a class number')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String baseUrl = 'https://iec-attendance-nodejs.onrender.com';
    final response = await http.get(Uri.parse('$baseUrl/faculty/dayExcel/drive/${_classController.text}'));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        excelLink = jsonResponse['link'] ?? '';
      });
      saveLinkToHistory(excelLink);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel generated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate Excel')),
      );
    }
  }

  Future<void> saveLinkToHistory(String link) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('excel_link_history') ?? [];
    history.add(link);
    await prefs.setStringList('excel_link_history', history);
  }

  Future<void> shareLink() async {
    final Uri url = Uri.parse(excelLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the link')),
      );
    }
  }

  void navigateToHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
  }

  @override
  void dispose() {
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generate Excel',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: navigateToHistory,
            tooltip: 'View History',
          ),
        ],
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
                'Generate Excel Report',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextField(
                controller: _classController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Class Number',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  prefixIcon: Icon(Icons.school, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    classNumber = value;
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: generateExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent.shade400,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Generate Excel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (excelLink.isNotEmpty) ...[
                Text(
                  'Generated Link:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SelectableText(
                      excelLink,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: shareLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent.shade400,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'Open Link',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}