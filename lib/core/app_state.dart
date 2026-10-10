import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

/// A date the user tracks (permit expiry, appointment at the Questura, …).
class TrackedDate {
  TrackedDate({
    required this.id,
    required this.title,
    required this.date,
    this.place = '',
    this.isPermit = false,
  });

  final int id;
  final String title;
  final DateTime date;
  final String place;
  final bool isPermit;

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'place': place,
        'isPermit': isPermit,
      };

  factory TrackedDate.fromJson(Map<String, dynamic> j) => TrackedDate(
        id: j['id'] as int,
        title: j['title'] as String,
        date: DateTime.parse(j['date'] as String),
        place: (j['place'] ?? '') as String,
        isPermit: (j['isPermit'] ?? false) as bool,
      );
}

/// All app state saved on the phone. Nothing personal leaves the device
/// except the photo sent for analysis (and it is not stored on the server).
class AppState extends ChangeNotifier {
  static const freeScansPerMonth = 3;

  late SharedPreferences _prefs;

  String language = 'ar';

  /// Translation language for lessons when the app itself is in Italian.
  String helpLanguage = 'ar';

  /// Language used for lesson translations and quiz questions.
  String get lessonLanguage => language == 'it' ? helpLanguage : language;

  List<TrackedDate> dates = [];
  Set<String> completedLessons = {};
  Set<int> reminderOffsets = {60, 30};
  bool isPremium = false; // set by the subscription flow (next version)
  int _scansUsed = 0;
  String _scanMonth = '';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    final saved = _prefs.getString('language');
    if (saved != null) {
      language = saved;
    } else {
      // First launch: use the phone's language if we support it.
      final phone = ui.PlatformDispatcher.instance.locale.languageCode;
      language = const ['ar', 'fr', 'it', 'en'].contains(phone) ? phone : 'ar';
    }

    helpLanguage = _prefs.getString('helpLanguage') ?? 'ar';

    final rawDates = _prefs.getString('dates');
    if (rawDates != null) {
      dates = (jsonDecode(rawDates) as List)
          .map((e) => TrackedDate.fromJson(e as Map<String, dynamic>))
          .toList();
      _sortDates();
    }
    completedLessons = (_prefs.getStringList('completedLessons') ?? []).toSet();
    final offsets = _prefs.getStringList('reminderOffsets');
    if (offsets != null) reminderOffsets = offsets.map(int.parse).toSet();
    isPremium = _prefs.getBool('isPremium') ?? false;
    _scansUsed = _prefs.getInt('scansUsed') ?? 0;
    _scanMonth = _prefs.getString('scanMonth') ?? '';
  }

  // ---------- language ----------
  Future<void> setLanguage(String code) async {
    language = code;
    await _prefs.setString('language', code);
    notifyListeners();
  }

  Future<void> setHelpLanguage(String code) async {
    helpLanguage = code;
    await _prefs.setString('helpLanguage', code);
    notifyListeners();
  }

  // ---------- dates ----------
  TrackedDate? get permit {
    for (final d in dates) {
      if (d.isPermit) return d;
    }
    return null;
  }

  Future<void> saveDate(TrackedDate date) async {
    dates.removeWhere((d) => d.id == date.id);
    if (date.isPermit) dates.removeWhere((d) => d.isPermit);
    dates.add(date);
    _sortDates();
    await _persistDates();
    await NotificationService.instance.scheduleFor(date, reminderOffsets);
    notifyListeners();
  }

  Future<void> deleteDate(TrackedDate date) async {
    dates.removeWhere((d) => d.id == date.id);
    await _persistDates();
    await NotificationService.instance.cancelFor(date);
    notifyListeners();
  }

  Future<void> toggleReminder(int daysBefore, bool on) async {
    on ? reminderOffsets.add(daysBefore) : reminderOffsets.remove(daysBefore);
    await _prefs.setStringList(
        'reminderOffsets', reminderOffsets.map((e) => '$e').toList());
    for (final d in dates) {
      await NotificationService.instance.scheduleFor(d, reminderOffsets);
    }
    notifyListeners();
  }

  int newDateId() => DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000;

  void _sortDates() => dates.sort((a, b) => a.date.compareTo(b.date));

  Future<void> _persistDates() => _prefs.setString(
      'dates', jsonEncode(dates.map((d) => d.toJson()).toList()));

  // ---------- lessons ----------
  Future<void> completeLesson(String id) async {
    completedLessons.add(id);
    await _prefs.setStringList('completedLessons', completedLessons.toList());
    notifyListeners();
  }

  // ---------- scans (free limit) ----------
  String get _thisMonth {
    final n = DateTime.now();
    return '${n.year}-${n.month}';
  }

  int get scansLeft {
    if (isPremium) return 999;
    final used = _scanMonth == _thisMonth ? _scansUsed : 0;
    return (freeScansPerMonth - used).clamp(0, freeScansPerMonth);
  }

  Future<void> registerScan() async {
    if (_scanMonth != _thisMonth) {
      _scanMonth = _thisMonth;
      _scansUsed = 0;
    }
    _scansUsed++;
    await _prefs.setInt('scansUsed', _scansUsed);
    await _prefs.setString('scanMonth', _scanMonth);
    notifyListeners();
  }
}

final appState = AppState();
