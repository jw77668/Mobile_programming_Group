import 'package:flutter/material.dart';
import 'note_models.dart'; // 모델 정의 import

// ------------------------------------
// 5. 메모 편집 페이지 (NoteEditPage)
// ------------------------------------
class NoteEditPage extends StatefulWidget {
  final Note? note;
  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();

  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '제목');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _contentController.addListener(_updateFormattingState);
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateFormattingState);
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _updateFormattingState() {
    setState(() {
      // 포맷팅 상태 분석 로직 (더미)
    });
  }

  void _toggleFormatting(String marker) {
    final selection = _contentController.selection;
    final text = _contentController.text;
    final selectedText = selection.textInside(text);

    String newText;
    int newSelectionEnd = selection.end;

    if (selectedText.startsWith(marker) && selectedText.endsWith(marker)) {
      newText = selectedText.substring(marker.length, selectedText.length - marker.length);
      _contentController.text = text.replaceRange(selection.start, selection.end, newText);
      newSelectionEnd = selection.start + newText.length;
    } else {
      newText = marker + selectedText + marker;
      _contentController.text = text.replaceRange(selection.start, selection.end, newText);
      newSelectionEnd = selection.start + newText.length;
    }

    _contentController.selection = TextSelection.collapsed(offset: newSelectionEnd);

    if (marker == '**') setState(() => _isBold = !_isBold);
    if (marker == '*') setState(() => _isItalic = !_isItalic);
  }

  void _saveAndReturnNote() {
    final title = _titleController.text.trim().isEmpty ? '제목 없음' : _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title == '제목 없음' && content.isEmpty && widget.note == null) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();

    if (widget.note != null) {
      widget.note!.title = title;
      widget.note!.content = content;
      widget.note!.modifiedDate = now;
      Navigator.pop(context, widget.note);
    } else {
      final newNote = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdDate: now,
        modifiedDate: now,
        type: NoteType.Text,
      );
      Navigator.pop(context, newNote);
    }
  }

  PreferredSizeWidget _buildCombinedAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: _saveAndReturnNote,
      ),
      title: TextField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          hintText: '제목',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.save, color: Colors.black), onPressed: _saveAndReturnNote),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            print("사진 넣기 기능 활성화");
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            print("텍스트 내 검색 기능 활성화");
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_contentFocusNode.hasFocus ? Icons.keyboard_hide : Icons.keyboard, color: Colors.black),
                onPressed: () {
                  setState(() {
                    if (_contentFocusNode.hasFocus) {
                      _contentFocusNode.unfocus(); // 키보드 닫기
                    } else {
                      _contentFocusNode.requestFocus(); // 키보드 열기
                    }
                  });
                },
              ),
              const VerticalDivider(width: 16, color: Colors.black12),
              IconButton(
                icon: Icon(Icons.format_bold, color: _isBold ? Colors.blueAccent : Colors.black54),
                onPressed: () => _toggleFormatting('**'),
              ),
              IconButton(
                icon: Icon(Icons.format_italic, color: _isItalic ? Colors.blueAccent : Colors.black54),
                onPressed: () => _toggleFormatting('*'),
              ),
              IconButton(
                icon: const Icon(Icons.format_underline, color: Colors.black54),
                onPressed: () {},
              ),
              const VerticalDivider(width: 16, color: Colors.black12),
              IconButton(
                icon: const Icon(Icons.text_fields, color: Colors.black),
                onPressed: () {},
              ),
              const Spacer(),

              // 6. Undo/Redo 버튼은 제거되었으며, 해당 자리에 기능이 없습니다.
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.black54),
                onPressed: () {}, // 기능 제거됨
              ),
              IconButton(
                icon: const Icon(Icons.redo, color: Colors.black54),
                onPressed: () {}, // 기능 제거됨
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCombinedAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: '메모를 시작하세요...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}