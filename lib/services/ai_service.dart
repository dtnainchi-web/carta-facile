import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Result of explaining a letter, already in the user's language.
class LetterExplanation {
  LetterExplanation({
    required this.sender,
    required this.summary,
    required this.details,
    required this.actions,
    this.deadline,
    this.deadlineLabel,
    this.isDemo = false,
  });

  /// True for the sample result shown when no AI server is connected yet.
  final bool isDemo;

  final String sender;
  final String summary;
  final String details;
  final List<String> actions;
  final DateTime? deadline;
  final String? deadlineLabel;

  factory LetterExplanation.fromJson(Map<String, dynamic> j) => LetterExplanation(
        sender: (j['sender'] ?? '') as String,
        summary: (j['summary'] ?? '') as String,
        details: (j['details'] ?? '') as String,
        actions: ((j['actions'] ?? []) as List).map((e) => '$e').toList(),
        deadline: j['deadline'] == null ? null : DateTime.tryParse('${j['deadline']}'),
        deadlineLabel: j['deadline_label'] as String?,
      );
}

/// An Italian letter written for the user, plus what it says in their language.
class LetterDraft {
  LetterDraft({required this.italian, required this.meaning, this.isDemo = false});
  final String italian;
  final String meaning;
  final bool isDemo;
}

/// Sends the photo to our Supabase Edge Function "explain-letter", which
/// calls the AI model. The AI key never lives in the app.
///
/// Build with:
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=your-publishable-key
class AiService {
  static const _baseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => _baseUrl.isNotEmpty && _anonKey.isNotEmpty;

  static Future<LetterExplanation> explain(Uint8List imageBytes, String language) async {
    if (!isConfigured) return _demo(language);
    final response = await http
        .post(
          Uri.parse('$_baseUrl/functions/v1/explain-letter'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_anonKey',
            'apikey': _anonKey,
          },
          body: jsonEncode({
            'image': base64Encode(imageBytes),
            'media_type': 'image/jpeg',
            'language': language,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('explain-letter failed: ${response.statusCode}');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return LetterExplanation.fromJson(data);
  }

  /// Writes a polite Italian letter from what the user typed in their language.
  /// Uses the Edge Function "write-letter".
  static Future<LetterDraft> writeLetter({
    required String recipient,
    required String message,
    required String language,
  }) async {
    if (!isConfigured) {
      await Future<void>.delayed(const Duration(seconds: 2));
      return LetterDraft(
        italian: 'Gentile Signor Rossi,\n\n'
            'Le scrivo per segnalarLe che lo scaldabagno dell\'appartamento non '
            'funziona da una settimana. Le chiedo cortesemente di farlo riparare '
            'il prima possibile.\n\nResto a disposizione per concordare un orario.\n\n'
            'Cordiali saluti,\n[Il tuo nome]',
        meaning: language == 'ar'
            ? 'رسالة مهذّبة لصاحب السكن تطلب إصلاح سخان الماء المعطّل منذ أسبوع، مع الاستعداد لتحديد موعد.'
            : language == 'fr'
                ? 'Une lettre polie au propriétaire demandant de réparer le chauffe-eau en panne depuis une semaine.'
                : 'A polite letter asking the landlord to repair the water heater, broken for a week.',
        isDemo: true,
      );
    }
    final response = await http
        .post(
          Uri.parse('$_baseUrl/functions/v1/write-letter'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_anonKey',
            'apikey': _anonKey,
          },
          body: jsonEncode({'recipient': recipient, 'message': message, 'language': language}),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      throw Exception('write-letter failed: ${response.statusCode}');
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return LetterDraft(
      italian: (data['italian'] ?? '') as String,
      meaning: (data['meaning'] ?? '') as String,
    );
  }

  /// Sample result for the preview, clearly marked as a demo in the UI.
  static Future<LetterExplanation> _demo(String language) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    const texts = {
      'ar': [
        'هذه الرسالة تستدعيك لأخذ البصمات',
        'تم استلام طلب تجديد إقامتك. يجب أن تحضر في التاريخ المذكور ومعك جواز السفر وإيصال البريد.',
        'أضف الموعد إلى تقويمك',
        'جهِّز جواز السفر والصور والإيصال',
        'موعد أخذ البصمات',
      ],
      'fr': [
        'Cette lettre vous convoque pour les empreintes',
        'Votre demande de renouvellement a été reçue. Présentez-vous à la date indiquée avec passeport et reçu de la poste.',
        'Ajoutez le rendez-vous à votre agenda',
        'Préparez passeport, photos et reçu',
        'Rendez-vous empreintes',
      ],
      'it': [
        'Questa lettera ti convoca per le impronte',
        'La domanda di rinnovo è stata ricevuta. Presentati alla data indicata con passaporto e ricevuta postale.',
        'Aggiungi l\'appuntamento al calendario',
        'Prepara passaporto, foto e ricevuta',
        'Appuntamento impronte',
      ],
      'en': [
        'This letter calls you in for fingerprints',
        'Your renewal application was received. Go on the date shown with your passport and post office receipt.',
        'Add the appointment to your calendar',
        'Prepare passport, photos and receipt',
        'Fingerprint appointment',
      ],
    };
    final t = texts[language] ?? texts['en']!;
    return LetterExplanation(
      sender: 'Questura',
      summary: t[0],
      details: t[1],
      actions: [t[2], t[3]],
      deadline: DateTime.now().add(const Duration(days: 6)),
      deadlineLabel: t[4],
      isDemo: true,
    );
  }
}
