import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note_editor_page.dart';
import 'note_models.dart';


class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late final Box<Note> _notesBox;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.modifiedDateDesc;

  @override
  void initState() {
    super.initState();
    _notesBox = Hive.box<Note>('notes');

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
            .where((note) {
              final query = _searchQuery.toLowerCase();
              return note.title.toLowerCase().contains(query) || 
                     note.plainText.toLowerCase().contains(query);
            })
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

  Future<void> _navigateToNoteEditor(BuildContext context, Note? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );
    if (result is Note) {
      await _notesBox.put(result.id, result);
    } else if (result == 'delete' && note != null) {
      await _notesBox.delete(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('노트 목록', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, color: theme.iconTheme.color),
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
            child: ValueListenableBuilder<Box<Note>>(
              valueListenable: _notesBox.listenable(),
              builder: (context, box, _) {
                final notes = _filterAndSortNotes(box);
                if (notes.isEmpty && _searchQuery.isEmpty) {
                  return const Center(child: Text('첫 메모를 작성해보세요.'));
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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToNoteEditor(context, null);
          },
          backgroundColor: Colors.lightBlue[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Icon(Icons.note_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: '검색',
          hintStyle: TextStyle(color: theme.hintColor),
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.hintColor),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note, Box<Note> box) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor, width: 1),
      ),
      child: ListTile(
        onTap: () => _navigateToNoteEditor(context, note),
        title: Text(
          note.title,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.plainText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                note.fullDateString,
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                note.isStarred ? Icons.star : Icons.star_border,
                color: note.isStarred ? Colors.amber[600] : theme.hintColor,
              ),
              onPressed: () {
                note.isStarred = !note.isStarred;
                box.put(note.id, note);
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: theme.iconTheme.color, size: 20),
              onPressed: () => _navigateToNoteEditor(context, note),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
              onPressed: () => box.delete(note.id),
            ),
          ],
        ),
      ),
    );
  }
}
