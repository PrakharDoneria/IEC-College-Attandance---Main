import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('excel_link_history') ?? [];
      history = history.reversed.toList();
    });
  }

  Future<void> copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Link copied to clipboard!')));
  }

  Future<void> openLink(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not launch the link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excel Link History')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: history.isEmpty
            ? Center(
                child: Text('No history available',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: SelectableText(
                        history[index],
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.teal),
                            onPressed: () => copyLink(history[index]),
                            tooltip: 'Copy Link',
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.open_in_browser, color: Colors.teal),
                            onPressed: () => openLink(history[index]),
                            tooltip: 'Open Link',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
