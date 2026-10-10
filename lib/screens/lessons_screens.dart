import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/app_state.dart';
import '../core/content.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  void _open(BuildContext context, Lesson lesson) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final lessons = ContentRepository.instance.lessons;
        final done = lessons.where((l) => appState.completedLessons.contains(l.id)).length;
        final next = lessons.firstWhere(
          (l) => !appState.completedLessons.contains(l.id),
          orElse: () => lessons.first,
        );

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 76,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('lessons_title')),
                Text(tr('lessons_sub'), style: text.bodySmall?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (appState.language == 'it') ...[
                const HelpLanguagePicker(),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('your_progress'),
                              style: text.bodySmall?.copyWith(color: const Color(0xFFC9D8E8))),
                          const SizedBox(height: 4),
                          Text('$done ${tr('of')} ${lessons.length} ${tr('lessons_word')}',
                              style: text.titleMedium?.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _open(context, next),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.ink,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(tr('continue')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < lessons.length; i++) ...[
                _LessonTile(
                  number: i + 1,
                  lesson: lessons[i],
                  done: appState.completedLessons.contains(lessons[i].id),
                  isNext: lessons[i].id == next.id && done < lessons.length,
                  onTap: () => _open(context, lessons[i]),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.number,
    required this.lesson,
    required this.done,
    required this.isNext,
    required this.onTap,
  });

  final int number;
  final Lesson lesson;
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isNext ? AppColors.primary : AppColors.line,
          width: isNext ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: done
                    ? AppColors.success
                    : isNext
                        ? AppColors.primary
                        : const Color(0xFFEEF0F3),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text('$number',
                        style: text.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isNext ? Colors.white : AppColors.muted)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pick(lesson.title),
                        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(secondLine(lesson.title, lesson.italianTitle),
                        textDirection: secondLineDirection,
                        style: text.bodySmall?.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              Text('${lesson.minutes} ${tr('minutes')}',
                  style: text.labelSmall?.copyWith(color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _tts = FlutterTts();
  int? _chosen;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('it-IT');
    _tts.setSpeechRate(0.45);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// Translation in the lesson language (Arabic/French/English).
  String _inLessonLang(Map<String, dynamic> m) =>
      (m[appState.lessonLanguage] ?? m['en'] ?? '').toString();

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: appState, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lesson = widget.lesson;
    final answered = _chosen != null;
    final correct = _chosen == lesson.quiz.answerIndex;

    return Scaffold(
      appBar: AppBar(title: Text(pick(lesson.title))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (appState.language == 'it') ...[
            const HelpLanguagePicker(),
            const SizedBox(height: 20),
          ],
          Text(tr('phrases'), style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final p in lesson.phrases) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.italian,
                              textDirection: TextDirection.ltr,
                              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(_inLessonLang(p.meaning),
                              textDirection: appState.lessonLanguage == 'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: text.bodyMedium?.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: p.italian,
                      onPressed: () => _tts.speak(p.italian),
                      icon: const Icon(Icons.volume_up_outlined, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          Text(tr('quiz'), style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_inLessonLang(lesson.quiz.question),
              textDirection:
                  appState.lessonLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              style: text.bodyLarge?.copyWith(height: 1.6)),
          const SizedBox(height: 12),
          for (var i = 0; i < lesson.quiz.options.length; i++) ...[
            _OptionButton(
              label: lesson.quiz.options[i],
              state: _chosen != i
                  ? _OptionState.idle
                  : (correct ? _OptionState.correct : _OptionState.wrong),
              onTap: () => setState(() => _chosen = i),
            ),
            const SizedBox(height: 8),
          ],
          if (answered)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(correct ? tr('correct') : tr('wrong'),
                  style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: correct ? AppColors.success : AppColors.accentText)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: correct
                ? () async {
                    await appState.completeLesson(lesson.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                : null,
            child: Text(tr('finish_lesson')),
          ),
        ],
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.label, required this.state, required this.onTap});
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border) = switch (state) {
      _OptionState.correct => (AppColors.successSoft, AppColors.success),
      _OptionState.wrong => (AppColors.accentSoft, AppColors.accent),
      _OptionState.idle => (Colors.white, AppColors.line),
    };
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        side: BorderSide(color: border, width: state == _OptionState.idle ? 1 : 2),
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(label, textDirection: TextDirection.ltr),
    );
  }
}
