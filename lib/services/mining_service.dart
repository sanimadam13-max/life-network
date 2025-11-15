import 'package:shared_preferences/shared_preferences.dart';

class MiningService {
  static const String _coinsKey = "life_network_coins";
  static const String _lastMineKey = "life_network_last_mine";

  /// Yawan coin da user zai samu cikin 24 hours
  final int coinsPerDay = 10;

  /// Samun SharedPreferences
  Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Karanta coin
  Future<int> getCoins() async {
    final p = await _prefs();
    return p.getInt(_coinsKey) ?? 0;
  }

  /// Adana coin
  Future<void> _saveCoins(int value) async {
    final p = await _prefs();
    await p.setInt(_coinsKey, value);
  }

  /// Lokacin mining na ƙarshe
  Future<DateTime?> getLastMiningTime() async {
    final p = await _prefs();
    final millis = p.getInt(_lastMineKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Adana sabon mining timestamp
  Future<void> _saveLastMiningTime() async {
    final p = await _prefs();
    await p.setInt(_lastMineKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Ko user ya gama 24 hours
  Future<bool> canMineNow() async {
    final last = await getLastMiningTime();
    if (last == null) return true;

    final diff = DateTime.now().difference(last).inHours;
    return diff >= 24;
  }

  /// Mining action
  Future<bool> mineCoins() async {
    if (await canMineNow()) {
      int currentCoins = await getCoins();
      int newBalance = currentCoins + coinsPerDay;

      await _saveCoins(newBalance);
      await _saveLastMiningTime();
      return true;
    }
    return false;
  }
}￼Enter
