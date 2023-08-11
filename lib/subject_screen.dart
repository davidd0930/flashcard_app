import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'flashcard_screen.dart';

class SubjectScreen extends StatefulWidget {
  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late List<Map<String, dynamic>> _subjects;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subjects = [];
    _refreshSubjectList();
  }

  _refreshSubjectList() async {
    final subjects = await _dbHelper.getSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  _deleteSubject(int id) async {
    await _dbHelper.deleteSubject(id);
    _refreshSubjectList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects'),
      ),
      body: ListView.builder(
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_subjects[index]['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FlashcardScreen(subjectId: _subjects[index]['id']),
                  ),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteSubject(_subjects[index]['id']),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Enter subject name'),
              content: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Subject Name'),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (_textController.text.isNotEmpty) {
                      await _dbHelper.insertSubject(_textController.text);
                      _refreshSubjectList();
                      _textController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
