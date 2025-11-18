import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note_editor_page.dart';
import 'note_models.dart';

// ------------------------------------
// 2. 메모 목록 페이지 (NoteListPage)
// ------------------------------------
class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  Box<Note>? _notesBox;
  SortOption _sortOption = SortOption.modifiedDateDesc;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    final box = await Hive.openBox<Note>('notesBox');
    if (mounted) {
      setState(() {
        _notesBox = box;
      });
    }
  }

  List<Note> get _sortedNotes {
    final list = _notesBox!.values.toList();
    _sort(list);
    return list;
  }

  void _sort(List<Note> list) {
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
  }

  void _sortNotes() {
    setState(() {});
  }

  Future<void> _navigateToNoteEditor(Note? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(note: note),
      ),
    );

    if (result is Note) {
      await _notesBox!.put(result.id, result);
      // ValueListenableBuilder가 업데이트를 처리하므로 _sortNotes() 호출이 필수는 아님
    }
  }

  String get _sortOptionText {
    switch (_sortOption) {
      case SortOption.modifiedDateDesc:
        return '수정 날짜 순 (최신)';
      case SortOption.modifiedDateAsc:
        return '수정 날짜 순 (오래됨)';
      case SortOption.titleAsc:
        return '제목 순 (가나다)';
      case SortOption.titleDesc:
        return '제목 순 (다나가)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notesBox == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ValueListenableBuilder<Box<Note>>(
      valueListenable: _notesBox!.listenable(),
      builder: (context, box, _) {
        final notes = _sortedNotes;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Smart Guide',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [],
          ),
          body: notes.isEmpty
              ? const Center(child: Text('첫 메모를 작성해주세요.'))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNoteListHeader(),
                const SizedBox(height: 16),
                _buildNoteGrid(notes),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToNoteEditor(null),
            tooltip: '새 노트 생성하기',
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildNoteListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '모든 노트',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<SortOption>(
          value: _sortOption,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
          underline: const SizedBox.shrink(),
          onChanged: (SortOption? newValue) {
            if (newValue != null) {
              setState(() {
                _sortOption = newValue;
              });
            }
          },
          items: const [
            DropdownMenuItem(
              value: SortOption.modifiedDateDesc,
              child: Text('수정 날짜 순 (최신)', style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
            DropdownMenuItem(
              value: SortOption.modifiedDateAsc,
              child: Text('수정 날짜 순 (오래됨)', style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
            DropdownMenuItem(
              value: SortOption.titleAsc,
              child: Text('제목 순 (가나다)', style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
            DropdownMenuItem(
              value: SortOption.titleDesc,
              child: Text('제목 순 (다나가)', style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ],
          hint: Text(_sortOptionText, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildNoteGrid(List<Note> notes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToNoteEditor(note),
          onLongPress: () => _showContextMenu(context, note),
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black),
                title: const Text('이름 편집', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('삭제', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _notesBox!.delete(note.id);
                  print('노트 ${note.title} 삭제 완료');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, Note note) {
    TextEditingController controller = TextEditingController(text: note.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('노트 이름 편집', style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: "새로운 이름을 입력하세요",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                note.title = controller.text;
                _notesBox!.put(note.id, note);
                Navigator.pop(context);
              },
              child: const Text('확인', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  // ⭐️ JSON 형식의 노드 내용을 일반 텍스트로 변환하는 헬퍼 함수
  String _getPlainText(String content) {
    if (content.isEmpty) {
      return '';
    }
    try {
      // JSON 형식인지 확인하고 파싱
      final List<dynamic> jsonData = jsonDecode(content);
      final doc = Document.fromJson(jsonData);
      // 순수 텍스트로 변환하여 반환
      return doc.toPlainText().trim();
    } catch (e) {
      // JSON 파싱에 실패하면, 일반 텍스트로 간주하고 그대로 반환
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ 변환된 텍스트를 가져옵니다.
    final plainTextContent = _getPlainText(note.content);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: note.type == NoteType.Locked ? Colors.grey : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: note.type == NoteType.Locked
                        ? const Icon(Icons.lock, color: Colors.grey, size: 30)
                        // ⭐️ 변환된 plainTextContent를 사용합니다.
                        : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        plainTextContent.isEmpty ? '내용 없음' : plainTextContent,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                note.dateString,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
