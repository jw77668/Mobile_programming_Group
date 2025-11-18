import 'package:flutter/material.dart';

// ------------------------------------
// 1. 모델 정의 (Note Data Structure)
// ------------------------------------
class Note {
  final String id;
  String title;
  String content;
  final DateTime createdDate;
  DateTime modifiedDate;
  final NoteType type;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.modifiedDate,
    this.type = NoteType.Text,
  });

  String get dateString {
    final now = DateTime.now();
    // 당일 생성된 노트는 '오전/오후 HH:MM' 형식으로 표시
    if (createdDate.day == now.day && createdDate.month == now.month && createdDate.year == now.year) {
      final hour = createdDate.hour;
      final minute = createdDate.minute;
      final ampm = hour < 12 ? '오전' : '오후';
      final displayHour = hour > 12 ? hour - 12 : hour;
      return '$ampm $displayHour:${minute.toString().padLeft(2, '0')}';
    }
    // 다른 날짜는 'MM월 DD일'
    return '${createdDate.month}월 ${createdDate.day}일';
  }
}

enum NoteType { Text, HandWriting, Locked }

// ------------------------------------
// 2. 메모 목록 페이지 (NoteListPage)
// ------------------------------------
class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  // 테스트 데이터: 실제 앱에서는 데이터베이스나 상태 관리로 대체됩니다.
  final List<Note> _notes = [
    Note(
        id: '1',
        title: '삼성 Note 편집',
        content: '여기는 노트 내용의 미리보기 텍스트가 들어가는 영역입니다.',
        createdDate: DateTime(2025, 11, 19, 11, 30),
        modifiedDate: DateTime(2025, 11, 19, 11, 30)),
    Note(
        id: '2',
        title: '음성녹음 테스트',
        content: '음성 녹음 노트는 내용 미리보기가 대신 아이콘으로 대체될 수 있습니다.',
        createdDate: DateTime(2025, 11, 19, 11, 22),
        modifiedDate: DateTime(2025, 11, 19, 11, 22)),
    Note(
        id: '3',
        title: '(제목)삼성노트',
        content: '이 노트는 제목이 아직 설정되지 않았을 경우의 예시입니다.',
        createdDate: DateTime(2025, 11, 19, 11, 28),
        modifiedDate: DateTime(2025, 11, 19, 11, 28)),
    Note(
        id: '4',
        title: '잠긴노트',
        content: '이 노트는 보안 잠금이 설정된 노트입니다.',
        createdDate: DateTime(2025, 11, 18, 10, 00),
        modifiedDate: DateTime(2025, 11, 18, 10, 00),
        type: NoteType.Locked),
    Note(
        id: '5',
        title: '팀 프로젝트 회의록',
        content: '세탁기 챗봇 기능 정의, UI/UX 설계 방향 확정.',
        createdDate: DateTime(2025, 11, 17, 9, 00),
        modifiedDate: DateTime(2025, 11, 17, 9, 00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Guide', // 메인 페이지와 동일한 앱 이름
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
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOneNoteSyncCard(), // OneNote 동기화 배너
            const SizedBox(height: 24),
            _buildNoteListHeader(), // '모든 노트' 제목 및 정렬 기능
            const SizedBox(height: 16),
            _buildNoteGrid(), // 노트 목록 그리드 뷰
          ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 메모 편집 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditPage()),
          );
        },
        tooltip: '새 노트 생성하기',
        backgroundColor: Colors.blueAccent, // 새 노트 생성 버튼 색상
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // OneNote 동기화 배너 위젯
  Widget _buildOneNoteSyncCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF1F222A), // 메인 페이지의 검색 카드와 동일한 어두운 색상
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '다양한 기기에서 내 노트를 확인하세요',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('나중에',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('사용해보기',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // '모든 노트' 제목 및 정렬 기능 위젯
  Widget _buildNoteListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '모든 노트', // 섹션 제목
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text('수정 날짜 순', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
          ],
        ),
      ],
    );
  }

  // 노트 그리드 뷰 구현
  Widget _buildNoteGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 가로 2개
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.8, // 카드 비율 조정
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return NoteCard(
          note: note,
          onTap: () {
            // 한 번 터치: 편집 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoteEditPage()),
            );
          },
          onLongPress: () => _showContextMenu(context, note), // 길게 누르기: 팝업 메뉴
        );
      },
    );
  }

  // 길게 눌렀을 때 팝업 메뉴 (삭제 및 이름 편집) 표시
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
                  Navigator.pop(context); // 팝업 닫기
                  _showRenameDialog(context, note); // 이름 편집 다이얼로그 표시
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('삭제', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // [기능 설명] 실제 삭제 로직은 setState(() => _notes.remove(note));를 통해 구현
                  print('노트 ${note.title} 삭제 요청');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 이름 편집 다이얼로그 (간단 구현)
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
                setState(() {
                  note.title = controller.text; // 이름 업데이트
                });
                Navigator.pop(context);
              },
              child: const Text('확인', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  // 노트 카드 위젯
  Widget _buildNoteCard(Note note) {
    return InkWell(
      onTap: () {
        // [기능 설명] 한 번 터치하면 편집 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEditPage()),
        );
      },
      onLongPress: () => _showContextMenu(context, note), // [기능 설명] 길게 누르면 메뉴 팝업
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
              // 노트 내용 영역 (미리보기)
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
                        ? const Icon(Icons.lock, color: Colors.grey, size: 40) // 잠긴 노트 아이콘
                        : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        note.content,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 노트 이름 (제목)
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

              // 날짜 (시간)
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
// ------------------------------------
// 4. 단일 메모 카드 위젯 (NoteCard)
// ------------------------------------
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

  @override
  Widget build(BuildContext context) {
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
              // 노트 내용 영역 (미리보기)
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
                        ? const Icon(Icons.lock, color: Colors.grey, size: 40) // 잠긴 노트 아이콘
                        : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        note.content,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 노트 이름 (제목)
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

              // 날짜 (시간)
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
// ------------------------------------
// 5. 메모 편집 페이지 (NoteEditPage - 더미)
// ------------------------------------
class NoteEditPage extends StatelessWidget {
  const NoteEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제목', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.brush, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.cut, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: '메모를 시작하세요...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // [기능 설명] 하단 메뉴 (키보드 영역)
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text('여기에 키보드 및 하단 메뉴가 표시됩니다.', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}