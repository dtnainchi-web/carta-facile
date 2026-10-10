import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Text in the four app languages: {"ar": ..., "fr": ..., "it": ..., "en": ...}
typedef Localized = Map<String, dynamic>;

class GuideStep {
  GuideStep(this.title, this.body, this.italianTerm);
  final Localized title;
  final Localized body;
  final String? italianTerm;
}

class Guide {
  Guide({
    required this.id,
    required this.icon,
    required this.title,
    required this.italianName,
    required this.steps,
    this.tip,
  });

  final String id;
  final String icon;
  final Localized title;
  final String italianName;
  final List<GuideStep> steps;
  final Localized? tip;

  factory Guide.fromJson(Map<String, dynamic> j) => Guide(
        id: j['id'] as String,
        icon: j['icon'] as String,
        title: j['title'] as Localized,
        italianName: j['italianName'] as String,
        tip: j['tip'] as Localized?,
        steps: (j['steps'] as List)
            .map((s) => GuideStep(
                  s['title'] as Localized,
                  s['body'] as Localized,
                  s['italianTerm'] as String?,
                ))
            .toList(),
      );
}

class Phrase {
  Phrase(this.italian, this.meaning);
  final String italian;
  final Localized meaning; // ar / fr / en (Italian is the phrase itself)
}

class QuizQuestion {
  QuizQuestion(this.question, this.options, this.answerIndex);
  final Localized question;
  final List<String> options; // in Italian
  final int answerIndex;
}

class Lesson {
  Lesson({
    required this.id,
    required this.title,
    required this.italianTitle,
    required this.minutes,
    required this.phrases,
    required this.quiz,
  });

  final String id;
  final Localized title;
  final String italianTitle;
  final int minutes;
  final List<Phrase> phrases;
  final QuizQuestion quiz;

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        title: j['title'] as Localized,
        italianTitle: j['italianTitle'] as String,
        minutes: j['minutes'] as int,
        phrases: (j['phrases'] as List)
            .map((p) => Phrase(p['it'] as String, p['meaning'] as Localized))
            .toList(),
        quiz: QuizQuestion(
          j['quiz']['question'] as Localized,
          (j['quiz']['options'] as List).cast<String>(),
          j['quiz']['answer'] as int,
        ),
      );
}

class ContentRepository {
  ContentRepository._();
  static final instance = ContentRepository._();

  List<Guide> guides = [];
  List<Lesson> lessons = [];

  Future<void> load() async {
    final g = jsonDecode(await rootBundle.loadString('assets/content/guides.json'));
    guides = (g as List).map((e) => Guide.fromJson(e as Map<String, dynamic>)).toList();
    final l = jsonDecode(await rootBundle.loadString('assets/content/lessons.json'));
    lessons = (l as List).map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }
}
