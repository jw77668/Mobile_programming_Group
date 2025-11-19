import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note_editor_page.dart';
import 'note_models.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late final Future<Box<Note>> _notesBoxFuture;
  SortOption _sortOption = SortOption.modifiedDateDesc;

  @override
  void initState() {
    super.initState();
    // ⭐️ 페이지가 시작될 때 데이터베이스를 여는 작업을 시작합니다.
    _notesBoxFuture = _initDatabase();
  }

  Future<Box<Note>> _initDatabase() async {
    // ⭐️ 이 페이지가 직접 Box를 엽니다.
    return await Hive.openBox<Note>('notesBox');
  }

  List<Note> _getSortedNotes(Box<Note> box) {
    final list = box.values.toList();
    switch (_sortOption) {
      case SortOption.modifiedDateDesc:
        list.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
        break;
      case SortOption.modifiedDateAsc:
        list.sort((a, b) => a.modifiedDate.compareTo(b.modifiedDate));
        break;
      case SortOption.titleAsc:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleDesc:
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }
    return list;
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
      appBar: _buildAppBar(),
      // ⭐️ FutureBuilder를 사용하여 Box가 열릴 때까지 기다립니다.
      body: FutureBuilder<Box<Note>>(
        future: _notesBoxFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('데이터 로딩 중 오류가 발생했습니다.\n오류: ${snapshot.error}'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notesBox = snapshot.data!;

          // ⭐️ Box가 준비되면, 실시간으로 화면을 그립니다.
          return ValueListenableBuilder<Box<Note>>(
            valueListenable: notesBox.listenable(),
            builder: (context, box, _) {
              final notes = _getSortedNotes(box);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildNoteListHeader(notes.length),
                    ),
                  ),
                  notes.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(child: Text('첫 메모를 작성해주세요.')),
                        )
                      : _buildNoteGrid(notes, box),
                ],
              );
            },
          );
        },
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ⭐️ Box가 열릴 때까지 기다린 후 페이지 이동
          final box = await _notesBoxFuture;
          _navigateToNoteEditor(context, box, null);
        },
        tooltip: '새 노트 생성하기',
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () { /* TODO: 검색 기능 구현 */ },
        ),
      ],
    );
  }

  Widget _buildNoteListHeader(int noteCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<SortOption>(
          value: _sortOption,
          icon: const Icon(Icons.arrow_downward, color: Colors.black, size: 16),
          underline: const SizedBox.shrink(),
          onChanged: (SortOption? newValue) {
            if (newValue != null) {
              setState(() {
                _sortOption = newValue;
              });
            }
          },
          items: const [
            DropdownMenuItem(value: SortOption.modifiedDateDesc, child: Text('수정 날짜 순', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: SortOption.modifiedDateAsc, child: Text('오래된 순', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: SortOption.titleAsc, child: Text('제목 오름차순', style: TextStyle(fontSize: 14))),
            DropdownMenuItem(value: SortOption.titleDesc, child: Text('제목 내림차순', style: TextStyle(fontSize: 14))),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteGrid(List<Note> notes, Box<Note> box) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              onTap: () => _navigateToNoteEditor(context, box, note),
            );
          },
          childCount: notes.length,
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  String _getPlainText(String content) {
    if (content.isEmpty) return '';
    try {
      final List<dynamic> jsonData = jsonDecode(content);
      final doc = Document.fromJson(jsonData);
      return doc.toPlainText().trim();
    } catch (e) {
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plainTextContent = _getPlainText(note.content);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plainTextContent.isEmpty ? '내용 없음' : plainTextContent,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                note.dateString,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
