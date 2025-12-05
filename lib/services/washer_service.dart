import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/washer_model.dart';

typedef WasherUpdateCallback = void Function(WasherModel? washer);

class WasherService with ChangeNotifier {
  static final WasherService _instance = WasherService._internal();

  factory WasherService() {
    return _instance;
  }

  WasherService._internal();

  WasherModel? _currentWasher;
  WasherUpdateCallback? onWasherUpdated;

  WasherModel? get currentWasher => _currentWasher;

  Future<void> loadInitialWasher() async {
    final prefs = await SharedPreferences.getInstance();
    final washerCode = prefs.getString('my_washer_code');
    if (washerCode != null) {
      try {
        _currentWasher = WasherModel.getDefaultWashers().firstWhere((w) => w.washerCode == washerCode);
      } catch (e) {
        _currentWasher = null;
      }
    }
    notifyListeners();
  }

  Future<void> updateWasher(WasherModel? newWasher) async {
    if (_currentWasher?.washerCode == newWasher?.washerCode) return;

    _currentWasher = newWasher;
    final prefs = await SharedPreferences.getInstance();
    if (newWasher != null) {
      await prefs.setString('my_washer_code', newWasher.washerCode);
    } else {
      await prefs.remove('my_washer_code');
    }
    notifyListeners();
    onWasherUpdated?.call(newWasher);
  }
}
