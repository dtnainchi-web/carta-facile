import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';

/// First launch: pick a language, then three short intro pages.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;

  static const _intro = [
    (Icons.description_outlined, 'onb1_title', 'onb1_body'),
    (Icons.document_scanner_outlined, 'onb2_title', 'onb2_body'),
    (Icons.notifications_active_outlined, 'onb3_title', 'onb3_body'),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _intro.length) {
      _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      appState.finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final last = _page == _intro.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: _page > 0 && !last
                  ? Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: appState.finishOnboarding,
                        child: Text(tr('skip')),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _LanguagePage(onPicked: _next),
                  for (final (icon, title, body) in _intro)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(icon, size: 56, color: AppColors.primary),
                          ),
                          const SizedBox(height: 32),
                          Text(tr(title),
                              textAlign: TextAlign.center,
                              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          Text(tr(body),
                              textAlign: TextAlign.center,
                              style: text.bodyLarge?.copyWith(color: AppColors.muted, height: 1.6)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_page > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= _intro.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.primary : const Color(0xFFD9DEE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: FilledButton(
                  style: last ? accentButtonStyle(context) : null,
                  onPressed: _next,
                  child: Text(last ? tr('start') : tr('next')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.onPicked});
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 88,
              height: 88,
              color: AppColors.primary,
              child: const Icon(Icons.task_outlined, color: Colors.white, size: 44),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Carta Facile',
            textAlign: TextAlign.center,
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 28),
        // Shown in all four languages so everyone understands the first step.
        Text('اختر لغتك · Choisissez votre langue\nScegli la tua lingua · Choose your language',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: text.bodyMedium?.copyWith(color: AppColors.muted, height: 1.7)),
        const SizedBox(height: 20),
        for (final code in supportedLanguages) ...[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              backgroundColor: appState.language == code ? AppColors.primarySoft : Colors.white,
              side: BorderSide(
                color: appState.language == code ? AppColors.primary : AppColors.line,
                width: appState.language == code ? 2 : 1,
              ),
            ),
            onPressed: () async {
              await appState.setLanguage(code);
              onPicked();
            },
            child: Text(languageNames[code]!,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
