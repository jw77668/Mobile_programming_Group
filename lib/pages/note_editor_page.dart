import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'note_models.dart';
import 'package:hive/hive.dart';
part 'note_editor_page.g.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;
  final String? initialContent;

  const NoteEditPage({super.key, this.note, this.initialContent});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  late Note _currentNote;
  bool _isNewNote = false;

  // For change detection
  late String _initialTitle;
  late String _initialContentJson;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;

    Document document;
    if (_isNewNote) {
      _currentNote = Note(
        id: const Uuid().v4(),
        title: '새 노트',
        content: '',
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      );
      if (widget.initialContent != null) {
        document = Document()..insert(0, widget.initialContent);
      } else {
        document = Document();
      }
    } else {
      _currentNote = widget.note!;
      try {
        document = _currentNote.content.isNotEmpty
            ? Document.fromJson(jsonDecode(_currentNote.content))
            : Document();
      } catch (e) {
        document = Document()..insert(0, _currentNote.content);
      }
    }

    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _initialContentJson = jsonEncode(_quillController.document.toDelta().toJson());

    _titleController = TextEditingController(text: _currentNote.title);
    _initialTitle = _currentNote.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    final currentTitle = _titleController.text;
    final currentContentJson = jsonEncode(_quillController.document.toDelta().toJson());
    return currentTitle != _initialTitle || currentContentJson != _initialContentJson;
  }

  Future<void> _promptToSaveAndExit() async {
    if (!_hasChanges()) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경 사항을 저장하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // 아니오
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // 예
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (shouldSave == null) {
      // Dialog dismissed, do nothing.
      return;
    }

    if (shouldSave) {
      _currentNote.title = _titleController.text.trim().isEmpty ? '제목 없음' : _titleController.text;
      _currentNote.content = jsonEncode(_quillController.document.toDelta().toJson());
      _currentNote.modifiedDate = DateTime.now();
      if (mounted) Navigator.pop(context, _currentNote);
    } else {
      if (mounted) Navigator.pop(context); // Exit without saving
    }
  }

  Future<void> _handleImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final index = _quillController.selection.baseOffset;
      final length = _quillController.selection.extentOffset - index;
      _quillController.replaceText(
          index, length, BlockEmbed.image(pickedFile.path), null);
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('전체 지우기'),
            onTap: () {
              _quillController.clear();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('노트 삭제'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              Navigator.pop(context, 'delete'); // Return 'delete' to the previous page
            },
          ),
        ],
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        await _promptToSaveAndExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _titleController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: '제목을 입력하세요', border: InputBorder.none),
            onEditingComplete: _promptToSaveAndExit,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.iconTheme.color),
          automaticallyImplyLeading: false, 
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _promptToSaveAndExit,
              tooltip: '저장',
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
              onPressed: () => _showMenu(context),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(

              child: SingleChildScrollView(

                scrollDirection: Axis.horizontal,

                child: Row(

                  children: [

// 실행 취소 (Undo)

                    QuillToolbarHistoryButton(

                      controller: _quillController,

                      isUndo: true,

                    ),

                    QuillToolbarHistoryButton(

                      controller: _quillController,

                      isUndo: false,

                    ),

                    const SizedBox(width: 8),



                    const SizedBox(width: 8, height: 20, child: VerticalDivider()),



// 텍스트 스타일

                    QuillToolbarToggleStyleButton(

                      controller: _quillController,

                      attribute: Attribute.bold,

                    ),

                    QuillToolbarToggleStyleButton(

                      controller: _quillController,

                      attribute: Attribute.italic,

                    ),

                    QuillToolbarToggleStyleButton(

                      controller: _quillController,

                      attribute: Attribute.underline,

                    ),

                    QuillToolbarToggleStyleButton(

                      controller: _quillController,

                      attribute: Attribute.strikeThrough,

                    ),



                    const SizedBox(width: 8, height: 20, child: VerticalDivider()),



// 색상 및 서식 지우기

                    QuillToolbarColorButton(

                      controller: _quillController,

                      isBackground: false,

                    ),

                    QuillToolbarClearFormatButton(

                      controller: _quillController,

                    ),



                    const SizedBox(width: 8, height: 20, child: VerticalDivider()),



// [그룹 5] 리스트

                    QuillToolbarToggleStyleButton(

                      controller: _quillController,

                      attribute: Attribute.ol,

                    ),

                    QuillToolbarToggleStyleButton(

                      controller: _quillController,

                      attribute: Attribute.ul,

                    ),



                    const SizedBox(width: 8, height: 20, child: VerticalDivider()),



// [그룹 6] 검색

                    QuillToolbarSearchButton(

                      controller: _quillController,

                    ),

                  ],

                ),

              ),

            ),

            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '수정됨: ${_currentNote.dateString}',
                style: TextStyle(fontSize: 15, height: 1.5, color: theme.textTheme.bodyLarge?.color),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: const QuillEditorConfig(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
    );
  }
}
