// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDB('flashcards.db');
    }
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Subjects (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Flashcards (
        id INTEGER PRIMARY KEY,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        subject_id INTEGER NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES Subjects (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertSubject(String name) async {
    final db = await database;
    final id = await db.insert('Subjects', {'name': name});
    return id;
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    final subjects = await db.query('Subjects');
    return subjects;
  }

  Future<int> insertFlashcard(int subjectId, String question, String answer) async {
    final db = await database;
    final id = await db.insert('Flashcards', {'subject_id': subjectId, 'question': question, 'answer': answer});
    return id;
  }

  Future<List<Map<String, dynamic>>> getFlashcards(int subjectId) async {
    final db = await database;
    final flashcards = await db.query('Flashcards', where: 'subject_id = ?', whereArgs: [subjectId]);
    return flashcards;
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    final count = await db.delete('Subjects', where: 'id = ?', whereArgs: [id]);
    return count;
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    final count = await db.delete('Flashcards', where: 'id = ?', whereArgs: [id]);
    return count;
  }
}
