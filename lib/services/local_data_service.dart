import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataService {
  static const String _smokingDataKey = 'smoking_data';
  static const String _userProfileKey = 'user_profile';
  static const String _settingsKey = 'app_settings';
  static const String _achievementsKey = 'achievements';
  static const String _cravingHistoryKey = 'craving_history';
  static const String _quitDateKey = 'quit_date';
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';

  // Singleton pattern
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalDataService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Onboarding Management
  Future<bool> hasCompletedOnboarding() async {
    await init();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await prefs.setBool(_hasCompletedOnboardingKey, completed);
  }

  // User Profile Management
  Future<Map<String, dynamic>?> getUserProfile() async {
    await init();
    final String? profileJson = prefs.getString(_userProfileKey);
    if (profileJson != null) {
      return json.decode(profileJson);
    }
    return null; // Return null for new users
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await init();
    await prefs.setString(_userProfileKey, json.encode(profile));
  }

  // Quit Date Management
  DateTime? getQuitDate() {
    if (_prefs == null) return null;
    final String? quitDateStr = prefs.getString(_quitDateKey);
    if (quitDateStr != null) {
      return DateTime.parse(quitDateStr);
    }
    return null; // Return null for new users
  }

  Future<void> setQuitDate(DateTime date) async {
    await init();
    await prefs.setString(_quitDateKey, date.toIso8601String());
  }

  Duration? getTimeSinceQuit() {
    final quitDate = getQuitDate();
    if (quitDate == null) return null;
    return DateTime.now().difference(quitDate);
  }

  // Smoking Data Management
  Future<List<Map<String, dynamic>>> getSmokingData() async {
    await init();
    final String? dataJson = prefs.getString(_smokingDataKey);
    if (dataJson != null) {
      final List<dynamic> decodedList = json.decode(dataJson);
      return decodedList.cast<Map<String, dynamic>>();
    }
    return []; // Return empty list for new users
  }

  Future<void> saveSmokingData(List<Map<String, dynamic>> data) async {
    await init();
    await prefs.setString(_smokingDataKey, json.encode(data));
  }

  Future<void> addSmokingEntry(Map<String, dynamic> entry) async {
    final currentData = await getSmokingData();
    entry['id'] = currentData.length + 1;
    entry['timestamp'] = DateTime.now().toIso8601String();
    currentData.insert(0, entry);
    await saveSmokingData(currentData);
  }

  Future<void> deleteSmokingEntry(int id) async {
    final currentData = await getSmokingData();
    currentData.removeWhere((entry) => entry['id'] == id);
    await saveSmokingData(currentData);
  }

  // Craving History Management
  Future<List<Map<String, dynamic>>> getCravingHistory() async {
    await init();
    final String? historyJson = prefs.getString(_cravingHistoryKey);
    if (historyJson != null) {
      final List<dynamic> decodedList = json.decode(historyJson);
      return decodedList.cast<Map<String, dynamic>>();
    }
    return []; // Return empty list for new users
  }

  Future<void> saveCravingHistory(List<Map<String, dynamic>> history) async {
    await init();
    await prefs.setString(_cravingHistoryKey, json.encode(history));
  }

  Future<void> addCravingEntry(Map<String, dynamic> entry) async {
    final currentHistory = await getCravingHistory();
    entry['id'] = currentHistory.length + 1;
    entry['timestamp'] = DateTime.now().toIso8601String();
    currentHistory.insert(0, entry);
    await saveCravingHistory(currentHistory);
  }

  // Achievements Management
  Future<List<Map<String, dynamic>>> getAchievements() async {
    await init();
    final String? achievementsJson = prefs.getString(_achievementsKey);
    if (achievementsJson != null) {
      final List<dynamic> decodedList = json.decode(achievementsJson);
      return decodedList.cast<Map<String, dynamic>>();
    }

    final achievements = _generateAchievements();
    await saveAchievements(achievements);
    return achievements;
  }

  List<Map<String, dynamic>> _generateAchievements() {
    final quitDate = getQuitDate();
    if (quitDate == null) return [];

    final timeSinceQuit = DateTime.now().difference(quitDate);
    final daysSinceQuit = timeSinceQuit.inDays;

    return [
      {
        "id": "first_hour",
        "name": "Primera hora",
        "description": "1 hora sin fumar",
        "level": "Bronce",
        "category": "milestone",
        "icon": "timer",
        "isUnlocked": daysSinceQuit >= 0,
        "unlockedAt": quitDate.add(const Duration(hours: 1)).toIso8601String(),
        "isRecent": daysSinceQuit == 0,
        "isNew": daysSinceQuit == 0,
      },
      {
        "id": "first_day",
        "name": "Primer día",
        "description": "24 horas sin fumar",
        "level": "Bronce",
        "category": "milestone",
        "icon": "flag",
        "isUnlocked": daysSinceQuit >= 1,
        "unlockedAt": daysSinceQuit >= 1
            ? quitDate.add(const Duration(days: 1)).toIso8601String()
            : null,
        "isRecent": daysSinceQuit <= 3 && daysSinceQuit >= 1,
        "isNew": daysSinceQuit == 1,
      },
      {
        "id": "three_days",
        "name": "Tres días",
        "description": "72 horas sin fumar - La nicotina se elimina",
        "level": "Plata",
        "category": "milestone",
        "icon": "favorite",
        "isUnlocked": daysSinceQuit >= 3,
        "unlockedAt": daysSinceQuit >= 3
            ? quitDate.add(const Duration(days: 3)).toIso8601String()
            : null,
        "isRecent": daysSinceQuit <= 5 && daysSinceQuit >= 3,
        "isNew": daysSinceQuit == 3,
      },
      {
        "id": "one_week",
        "name": "Una semana",
        "description": "7 días sin fumar",
        "level": "Plata",
        "category": "milestone",
        "icon": "calendar_today",
        "isUnlocked": daysSinceQuit >= 7,
        "unlockedAt": daysSinceQuit >= 7
            ? quitDate.add(const Duration(days: 7)).toIso8601String()
            : null,
        "isRecent": daysSinceQuit <= 9 && daysSinceQuit >= 7,
        "isNew": daysSinceQuit == 7,
      },
      {
        "id": "money_saver",
        "name": "Ahorrador",
        "description": "Ahorraste más de €20",
        "level": "Oro",
        "category": "savings",
        "icon": "savings",
        "isUnlocked": daysSinceQuit >= 2, // Assuming savings after 2 days
        "unlockedAt": daysSinceQuit >= 2
            ? quitDate.add(const Duration(days: 2)).toIso8601String()
            : null,
        "isRecent": daysSinceQuit <= 4 && daysSinceQuit >= 2,
        "isNew": daysSinceQuit == 2,
      },
    ];
  }

  Future<void> saveAchievements(List<Map<String, dynamic>> achievements) async {
    await init();
    await prefs.setString(_achievementsKey, json.encode(achievements));
  }

  // Settings Management
  Future<Map<String, dynamic>> getSettings() async {
    await init();
    final String? settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      return json.decode(settingsJson);
    }

    // Return default settings
    final defaultSettings = {
      'language': 'es',
      'notifications': true,
      'reminders': true,
      'progressSharing': false,
      'darkMode': false,
      'biometricAuth': false,
      'dataSharing': false,
      'analyticsParticipation': true,
      'communityVisibility': true,
      'healthKitIntegration': false,
      'googleFitIntegration': false,
    };

    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await init();
    await prefs.setString(_settingsKey, json.encode(settings));
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final currentSettings = await getSettings();
    currentSettings[key] = value;
    await saveSettings(currentSettings);
  }

  // Statistics and Analytics (Local calculations)
  Map<String, dynamic> calculateStatistics() {
    final quitDate = getQuitDate();
    if (quitDate == null) return {};

    final timeSinceQuit = DateTime.now().difference(quitDate);
    final daysSinceQuit = timeSinceQuit.inDays;
    final hoursSinceQuit = timeSinceQuit.inHours;
    final minutesSinceQuit = timeSinceQuit.inMinutes;

    // Mock user data for calculations
    const cigarettesPerDay = 20;
    const costPerPack = 5.50;
    const cigarettesPerPack = 20;
    const costPerCigarette = costPerPack / cigarettesPerPack;

    final cigarettesAvoided = (daysSinceQuit * cigarettesPerDay) +
        ((hoursSinceQuit % 24) * (cigarettesPerDay / 24)).round();
    final moneySaved = cigarettesAvoided * costPerCigarette;
    final timeRegained = cigarettesAvoided * 5; // 5 minutes per cigarette

    return {
      'daysSinceQuit': daysSinceQuit,
      'hoursSinceQuit': hoursSinceQuit,
      'minutesSinceQuit': minutesSinceQuit,
      'cigarettesAvoided': cigarettesAvoided,
      'moneySaved': moneySaved,
      'timeRegained': timeRegained,
      'timeSinceQuit': timeSinceQuit,
    };
  }

  // Weekly progress data
  List<Map<String, dynamic>> getWeeklyProgressData() {
    // Return empty data for new users - will be populated as they use the app
    final now = DateTime.now();
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final dayName = weekdays[day.weekday - 1];

      return {
        'day': dayName,
        'count': 0, // Start with 0 for new users
        'goal': 10,
        'date': day.toIso8601String(),
      };
    });
  }

  // Health benefits data
  List<String> getHealthBenefits() {
    final stats = calculateStatistics();
    final daysSinceQuit = stats['daysSinceQuit'] ?? 0;

    List<String> benefits = [];

    if (daysSinceQuit >= 0) {
      benefits.add("Tu cuerpo comienza a eliminar la nicotina");
    }

    if (daysSinceQuit >= 1) {
      benefits.add("Tu riesgo de ataque cardíaco comienza a disminuir");
      benefits.add("Tus niveles de oxígeno en sangre están normalizándose");
    }

    if (daysSinceQuit >= 2) {
      benefits.add("Tu sentido del gusto y olfato está mejorando");
    }

    if (daysSinceQuit >= 3) {
      benefits.add("Tu circulación sanguínea está mejorando");
    }

    if (daysSinceQuit >= 7) {
      benefits.add("Tus pulmones están comenzando a limpiarse");
      benefits.add("Tu capacidad pulmonar está aumentando");
    }

    if (benefits.isEmpty) {
      benefits.add(
          "¡Felicidades por comenzar tu viaje hacia una vida libre de humo!");
    }

    return benefits;
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await init();
    await prefs.remove(_smokingDataKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_cravingHistoryKey);
    await prefs.remove(_quitDateKey);
  }

  // Export data functionality
  Future<String> exportDataAsJSON() async {
    final userData = {
      'profile': await getUserProfile(),
      'smokingData': await getSmokingData(),
      'cravingHistory': await getCravingHistory(),
      'achievements': await getAchievements(),
      'settings': await getSettings(),
      'statistics': calculateStatistics(),
      'exportDate': DateTime.now().toIso8601String(),
    };

    return json.encode(userData);
  }

  Future<String> exportDataAsCSV() async {
    final smokingData = await getSmokingData();
    final cravingHistory = await getCravingHistory();

    StringBuffer csv = StringBuffer();

    // CSV Header for smoking data
    csv.writeln('Type,Date,Time,Location,Trigger,Note,Intensity');

    // Add smoking data
    for (var entry in smokingData) {
      final timestamp = DateTime.parse(entry['timestamp']);
      csv.writeln(
          'Smoking,${timestamp.day}/${timestamp.month}/${timestamp.year},'
          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')},'
          '${entry['location'] ?? ''},'
          '${entry['trigger'] ?? ''},'
          '${entry['note'] ?? ''},'
          '${entry['intensity'] ?? ''}');
    }

    // Add craving data
    for (var entry in cravingHistory) {
      final timestamp = DateTime.parse(entry['timestamp']);
      csv.writeln(
          'Craving,${timestamp.day}/${timestamp.month}/${timestamp.year},'
          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')},'
          '${entry['location'] ?? ''},'
          '${entry['trigger'] ?? ''},'
          'Success: ${entry['success']}, Technique: ${entry['technique']},'
          '${entry['intensity'] ?? ''}');
    }

    return csv.toString();
  }
}
