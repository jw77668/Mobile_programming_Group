import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note_editor_page.dart';
import 'note_models.dart';

part 'notes_list_page.g.dart';


class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late final Future<Box<Note>> _notesBoxFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.modifiedDateDesc;

  @override
  void initState() {
    super.initState();
    _notesBoxFuture = Hive.openBox<Note>('notesBox_v3');

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterAndSortNotes(Box<Note> box) {
    final filteredNotes = _searchQuery.isEmpty
        ? box.values.toList()
        : box.values
            .where((note) =>
                note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    filteredNotes.sort((a, b) {
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;

      switch (_sortOption) {
        case SortOption.modifiedDateDesc:
          return b.modifiedDate.compareTo(a.modifiedDate);
        case SortOption.modifiedDateAsc:
          return a.modifiedDate.compareTo(b.modifiedDate);
        case SortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.titleDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      }
    });
    return filteredNotes;
  }

  Future<void> _navigateToNoteEditor(BuildContext context, Box<Note> box, Note? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );
    if (result is Note) {
      await box.put(result.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('노트 목록', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: (SortOption result) {
              setState(() {
                _sortOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.modifiedDateDesc,
                child: Text('수정일자 (최신순)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.modifiedDateAsc,
                child: Text('수정일자 (오래된순)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleAsc,
                child: Text('제목 (오름차순)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleDesc,
                child: Text('제목 (내림차순)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<Box<Note>>(
              future: _notesBoxFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류: ${snapshot.error}'));
                }

                final notesBox = snapshot.data!;
                return ValueListenableBuilder<Box<Note>>(
                  valueListenable: notesBox.listenable(),
                  builder: (context, box, _) {
                    final notes = _filterAndSortNotes(box);
                    if (notes.isEmpty && _searchQuery.isEmpty) {
                      return const Center(child: Text('첫 노트를 작성해보세요.'));
                    }
                    if (notes.isEmpty && _searchQuery.isNotEmpty) {
                      return const Center(child: Text('검색 결과가 없습니다.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _buildNoteItem(context, note, box);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final box = await _notesBoxFuture;
            _navigateToNoteEditor(context, box, null);
          },
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add)
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: '검색',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note, Box<Note> box) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        onTap: () => _navigateToNoteEditor(context, box, note),
        title: Text(
          note.title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            note.fullDateString,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                note.isStarred ? Icons.star : Icons.star_border,
                color: note.isStarred ? Colors.amber[600] : Colors.grey,
              ),
              onPressed: () {
                note.isStarred = !note.isStarred;
                box.put(note.id, note);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
              onPressed: () => _navigateToNoteEditor(context, box, note),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
              onPressed: () => box.delete(note.id),
            ),
          ],
        ),
      ),
    );
  }
}
