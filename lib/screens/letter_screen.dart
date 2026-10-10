import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';
import 'settings_screens.dart';

/// The user writes in their language what they want to say; the AI writes
/// a polite Italian letter and explains what it says.
class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  static const _recipients = ['to_landlord', 'to_employer', 'to_office', 'to_school', 'to_other'];

  final _message = TextEditingController();
  String _recipient = 'to_landlord';
  LetterDraft? _draft;
  bool _loading = false;
  bool _limitReached = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _write() async {
    FocusScope.of(context).unfocus();
    if (AiService.isConfigured && appState.lettersLeft <= 0) {
      setState(() => _limitReached = true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _draft = null;
    });
    try {
      final draft = await AiService.writeLetter(
        // Recipient sent in English so the server prompt stays simple.
        recipient: _recipient.replaceFirst('to_', ''),
        message: _message.text.trim(),
        language: appState.language,
      );
      if (!draft.isDemo) await appState.registerLetter();
      if (mounted) setState(() => _draft = draft);
    } catch (_) {
      if (mounted) setState(() => _error = tr('error_generic'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final d = _draft;
    return Scaffold(
      appBar: AppBar(title: Text(tr('tool_letter'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tr('letter_intro'), style: text.bodyLarge?.copyWith(height: 1.6)),
          const SizedBox(height: 16),
          Text(tr('letter_to'), style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in _recipients)
                ChoiceChip(
                  label: Text(tr(r)),
                  selected: _recipient == r,
                  onSelected: (_) => setState(() => _recipient = r),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _message,
            minLines: 4,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: tr('letter_hint'),
              hintMaxLines: 3,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading || _message.text.trim().length < 5 ? null : _write,
            icon: const Icon(Icons.auto_awesome),
            label: Text(tr('write_it')),
          ),
          if (!appState.isPremium && AiService.isConfigured) ...[
            const SizedBox(height: 8),
            Text('${tr('letters_left')} ${appState.lettersLeft}',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: AppColors.muted)),
          ],
          if (_limitReached) ...[
            const SizedBox(height: 16),
            LimitReachedBox(message: tr('letter_limit_reached')),
          ],
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(tr('writing')),
              ]),
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: text.bodyMedium?.copyWith(color: AppColors.accentText)),
          ],
          if (d != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(tr('letter_italian'),
                              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (d.isDemo)
                          const Pill('DEMO',
                              background: AppColors.accentSoft, foreground: AppColors.accentText),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SelectableText(d.italian,
                        textDirection: TextDirection.ltr,
                        style: text.bodyMedium?.copyWith(height: 1.7)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: d.italian));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(tr('copied'))));
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(tr('copy')),
                    ),
                  ],
                ),
              ),
            ),
            if (appState.language != 'it' && d.meaning.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('letter_meaning'),
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(d.meaning, style: text.bodyMedium?.copyWith(height: 1.7)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Disclaimer(),
          ],
        ],
      ),
    );
  }
}
