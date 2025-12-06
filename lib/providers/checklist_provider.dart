import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/checklist_model.dart';

class ChecklistProvider with ChangeNotifier {
  final String? _userEmail;
  final Box _box;
  final Uuid _uuid = const Uuid();

  List<ChecklistItem> _items = [];
  List<ChecklistItem> get items => _items;

  ChecklistProvider() : _userEmail = Hive.box('session').get('current_user'), _box = Hive.box('checklists') {
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (_userEmail == null) return;

    final data = _box.get(_userEmail);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _items = jsonList.map((json) => ChecklistItem.fromJson(json)).toList();
    } else {
      await _createTemplateItems();
    }
    notifyListeners();
  }

  Future<void> _createTemplateItems() async {
    _items = [
      ChecklistItem(id: _uuid.v4(), title: '세탁기 문 열어두기', period: '매주'),
      ChecklistItem(id: _uuid.v4(), title: '세제 투입구 물기 닦기', period: '매주'),
      ChecklistItem(id: _uuid.v4(), title: '세제 투입구 분리하여 물청소하기', period: '매월'),
      ChecklistItem(id: _uuid.v4(), title: '도어 고무패킹(가스켓) 닦기', period: '매월'),
      ChecklistItem(id: _uuid.v4(), title: '거름망(배수 필터) 청소하기', period: '매월'),
      ChecklistItem(id: _uuid.v4(), title: '세탁조 클리너로 통세척 코스 돌리기', period: '매월'),
    ];
    await _saveItems();
  }

  Future<void> _saveItems() async {
    if (_userEmail == null) return;
    final jsonString = jsonEncode(_items.map((item) => item.toJson()).toList());
    await _box.put(_userEmail, jsonString);
  }

  Future<void> addItem(String title, String period) async {
    final newItem = ChecklistItem(
      id: _uuid.v4(),
      title: title,
      period: period,
    );
    _items = [..._items, newItem];
    await _saveItems();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items = _items.where((item) => item.id != id).toList();
    await _saveItems();
    notifyListeners();
  }

  Future<void> toggleItem(String id) async {
    _items = _items.map((item) {
      if (item.id == id) {
        return ChecklistItem(
            id: item.id,
            title: item.title,
            period: item.period,
            isDone: !item.isDone,
            reminder: item.reminder);
      }
      return item;
    }).toList();
    await _saveItems();
    notifyListeners();
  }

  Future<void> setReminder(String id, Duration duration) async {
    _items = _items.map((item) {
      if (item.id == id) {
        return ChecklistItem(
            id: item.id,
            title: item.title,
            period: item.period,
            isDone: item.isDone,
            reminder: DateTime.now().add(duration));
      }
      return item;
    }).toList();
    await _saveItems();
    notifyListeners();
  }

  Future<void> cancelReminder(String id) async {
    _items = _items.map((item) {
      if (item.id == id) {
        return ChecklistItem(
            id: item.id,
            title: item.title,
            period: item.period,
            isDone: item.isDone,
            reminder: null);
      }
      return item;
    }).toList();
    await _saveItems();
    notifyListeners();
  }
}
