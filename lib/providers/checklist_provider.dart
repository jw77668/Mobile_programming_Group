import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/checklist_model.dart';

class ChecklistProvider with ChangeNotifier {
  final List<ChecklistItem> _items = [];
  final Uuid _uuid = const Uuid();

  List<ChecklistItem> get items => _items;

  ChecklistProvider() {
    _loadTemplateItems();
  }

  void _loadTemplateItems() {
    _items.addAll([
      // 매주
      ChecklistItem(id: _uuid.v4(), title: '세탁기 문 열어두기', period: '매주'),
      ChecklistItem(id: _uuid.v4(), title: '세제 투입구 물기 닦기', period: '매주'),
      // 매월
      ChecklistItem(id: _uuid.v4(), title: '세제 투입구 분리하여 물청소하기', period: '매월'),
      ChecklistItem(id: _uuid.v4(), title: '도어 고무패킹(가스켓) 닦기', period: '매월'),
      ChecklistItem(id: _uuid.v4(), title: '거름망(배수 필터) 청소하기', period: '매월'),
      ChecklistItem(id: _uuid.v4(), title: '세탁조 클리너로 통세척 코스 돌리기', period: '매월'),
    ]);
    notifyListeners();
  }

  void toggleItem(String id) {
    final item = _items.firstWhere((item) => item.id == id);
    item.isDone = !item.isDone;
    notifyListeners();
  }

  void setReminder(String id, Duration duration) {
    final item = _items.firstWhere((item) => item.id == id);
    item.reminder = DateTime.now().add(duration);
    notifyListeners();
  }

  void cancelReminder(String id) {
    final item = _items.firstWhere((item) => item.id == id);
    item.reminder = null;
    notifyListeners();
  }
}
