import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'note_models.dart';
import 'package:hive/hive.dart';
part 'note_editor_page.g.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, required this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  late Note _currentNote;
  bool _isNewNote = false;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;

    if (_isNewNote) {
      _currentNote = Note(
        id: const Uuid().v4(),
        title: '새 노트',
        content: '',
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      );
      _quillController = QuillController.basic();
    } else {
      _currentNote = widget.note!;
      try {
        final document = _currentNote.content.isNotEmpty
            ? Document.fromJson(jsonDecode(_currentNote.content))
            : Document();
        _quillController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        final document = Document()..insert(0, _currentNote.content);
        _quillController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }

    _titleController = TextEditingController(text: _currentNote.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _saveAndReturn() {
    _currentNote.title = _titleController.text.trim().isEmpty ? '제목 없음' : _titleController.text;
    _currentNote.content = jsonEncode(_quillController.document.toDelta().toJson());
    _currentNote.modifiedDate = DateTime.now();
    Navigator.pop(context, _currentNote);
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

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _handleImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _handleImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: '제목을 입력하세요', border: InputBorder.none),
          onEditingComplete: _saveAndReturn,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _saveAndReturn,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: _saveAndReturn,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _showImageSourceActionSheet,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuillSimpleToolbar(
            controller: _quillController,
            config: const QuillSimpleToolbarConfig(
              showSearchButton: true,
              showFontFamily: false,
              showCodeBlock: false,
              showQuote: false,
              showListCheck: false,
              showIndent: false,
              showLink: false,
              showSuperscript: false,
              showSubscript: false,
              showRedo: false,
              showUndo: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '수정됨: ${_currentNote.dateString}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
      backgroundColor: Colors.white,
    );
  }
}
