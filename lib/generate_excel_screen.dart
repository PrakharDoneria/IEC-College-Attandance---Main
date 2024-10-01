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

  Future<void> generateExcel() async {
    if (classNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a class number')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String baseUrl = 'https://iec-group-of-institutions.onrender.com';
    final response = await http.get(Uri.parse('$baseUrl/dayExcel=$classNumber'));

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        excelLink = jsonResponse['link'] ?? '';
      });
      saveLinkToHistory(excelLink);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel generated!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate Excel')));
      print('Error occurred: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> saveLinkToHistory(String link) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('excel_link_history') ?? [];
    history.add(link);
    await prefs.setStringList('excel_link_history', history);
  }

  Future<void> shareLink() async {
    if (await canLaunch(excelLink)) {
      await launch(excelLink);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch the link')));
    }
  }

  void navigateToHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Excel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: navigateToHistory,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Class Number',
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
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  classNumber = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateExcel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Generate Excel', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 20),
            if (isLoading) 
              Center(child: CircularProgressIndicator())
            else if (excelLink.isNotEmpty) ...[
              Text('Generated Excel Link:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SelectableText(
                    excelLink,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: shareLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Share Link', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
