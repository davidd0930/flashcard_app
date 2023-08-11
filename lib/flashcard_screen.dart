import 'package:flutter/material.dart';
import 'database_helper.dart';

class FlashcardScreen extends StatefulWidget {
  final int subjectId;

  FlashcardScreen({required this.subjectId});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  late List<Map<String, dynamic>> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _flashcards = [];
    _refreshFlashcardList();
  }

  _refreshFlashcardList() async {
    final flashcards = await _dbHelper.getFlashcards(widget.subjectId);
    setState(() {
      _flashcards = flashcards;
    });
  }

  _deleteFlashcard(int id) async {
    await _dbHelper.deleteFlashcard(id);
    _refreshFlashcardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards'),
      ),
      body: ListView.builder(
        itemCount: _flashcards.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_flashcards[index]['question']),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(_flashcards[index]['question']),
                    content: Text(_flashcards[index]['answer']),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteFlashcard(_flashcards[index]['id']),
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
              title: Text('Enter flashcard details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(labelText: 'Question'),
                  ),
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(labelText: 'Answer'),
                    maxLines: null,
                  ),
                ],
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
                    if (_questionController.text.isNotEmpty &&
                        _answerController.text.isNotEmpty) {
                      await _dbHelper.insertFlashcard(widget.subjectId,
                          _questionController.text, _answerController.text);
                      _refreshFlashcardList();
                      _questionController.clear();
                      _answerController.clear();
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
