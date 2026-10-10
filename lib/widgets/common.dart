import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';

/// Icon + soft background color for each document type in guides.json.
({IconData icon, Color color, Color soft}) guideVisual(String key) {
  switch (key) {
    case 'permit':
      return (icon: Icons.badge_outlined, color: AppColors.primary, soft: AppColors.primarySoft);
    case 'health':
      return (icon: Icons.favorite_border, color: AppColors.success, soft: AppColors.successSoft);
    case 'home':
      return (icon: Icons.home_work_outlined, color: AppColors.accentText, soft: AppColors.accentSoft);
    case 'tax':
      return (icon: Icons.receipt_long_outlined, color: const Color(0xFF5B47A0), soft: const Color(0xFFEEEAF7));
    case 'family':
      return (icon: Icons.family_restroom, color: const Color(0xFFB0413E), soft: const Color(0xFFFBE9E8));
    case 'flag':
      return (icon: Icons.flag_outlined, color: AppColors.success, soft: AppColors.successSoft);
    case 'car':
      return (icon: Icons.directions_car_outlined, color: AppColors.primary, soft: AppColors.primarySoft);
    case 'isee':
      return (icon: Icons.euro_outlined, color: AppColors.accentText, soft: AppColors.accentSoft);
    default:
      return (icon: Icons.description_outlined, color: AppColors.primary, soft: AppColors.primarySoft);
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.background = AppColors.primarySoft, this.foreground = AppColors.primary});
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600)),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      );
}

/// Small note shown under AI explanations and guides.
class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tr('disclaimer'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
          ),
        ],
      );
}

/// Bottom sheet to pick one of the four languages.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in supportedLanguages)
            ListTile(
              minTileHeight: 56,
              title: Text(languageNames[code]!),
              trailing: appState.language == code
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                appState.setLanguage(code);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

/// Shown when the app is in Italian: which language translations use.
class HelpLanguagePicker extends StatelessWidget {
  const HelpLanguagePicker({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('translation_in'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              for (final code in const ['ar', 'fr', 'en'])
                ButtonSegment(value: code, label: Text(languageNames[code]!)),
            ],
            selected: {appState.helpLanguage},
            onSelectionChanged: (s) => appState.setHelpLanguage(s.first),
          ),
        ],
      );
}

String formatDate(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatMediumDate(d);
