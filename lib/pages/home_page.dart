import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import 'note_form_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Load notes dari local storage
  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotes = prefs.getStringList('notes');

    if (savedNotes != null) {
      setState(() {
        notes = savedNotes.map((e) => Note.fromJson(e)).toList();
      });
    }
  }

  // Simpan notes ke local storage
  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> noteList =
        notes.map((note) => note.toJson()).toList();
    await prefs.setStringList('notes', noteList);
  }

  // Logout
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('login');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // Format tanggal
  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Daily Notes"),
        backgroundColor: Color(0xFF6C63FF),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6C63FF),
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteFormPage()),
          );
          if (result != null) {
            setState(() => notes.add(result));
            saveNotes(); // 🔥 SIMPAN
          }
        },
      ),

      body: notes.isEmpty
          ? Center(
              child: Text(
                "Belum ada catatan",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (_, i) => Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
  onTap: () async {
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormPage(note: notes[i]),
      ),
    );

    if (updatedNote != null) {
      setState(() {
        notes[i] = updatedNote;
      });
      saveNotes(); // 🔥 SIMPAN PERUBAHAN
    }
  },
  title: Text(
    notes[i].title,
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 6),
      Text(notes[i].content),
      SizedBox(height: 8),
      Row(
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            formatDate(notes[i].date),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ],
  ),
  trailing: IconButton(
    icon: Icon(Icons.delete, color: Colors.redAccent),
    onPressed: () {
      setState(() => notes.removeAt(i));
      saveNotes();
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
