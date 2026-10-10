import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../services/ai_service.dart';
import '../widgets/common.dart';
import 'tracker_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  Uint8List? _image;
  LetterExplanation? _result;
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    if (appState.scansLeft <= 0) {
      setState(() => _error = tr('scan_limit_reached'));
      return;
    }
    final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _image = bytes;
      _result = null;
      _error = null;
      _loading = true;
    });
    try {
      final result = await AiService.explain(bytes, appState.language);
      if (!result.isDemo) await appState.registerScan();
      if (!mounted) return;
      setState(() => _result = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = tr('error_generic'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _reset() => setState(() {
        _image = null;
        _result = null;
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(tr('scan_title'))),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_image == null) ..._intro(context) else ..._resultView(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _intro(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return [
      Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.document_scanner_outlined, size: 64, color: AppColors.primary),
      ),
      const SizedBox(height: 20),
      Text(tr('scan_intro'), style: text.titleMedium?.copyWith(height: 1.6)),
      const SizedBox(height: 24),
      FilledButton.icon(
        style: accentButtonStyle(context),
        onPressed: () => _pick(ImageSource.camera),
        icon: const Icon(Icons.photo_camera_outlined),
        label: Text(tr('take_photo')),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => _pick(ImageSource.gallery),
        icon: const Icon(Icons.photo_library_outlined),
        label: Text(tr('from_gallery')),
      ),
      const SizedBox(height: 16),
      if (!appState.isPremium)
        Text('${tr('scans_left')} ${appState.scansLeft}',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: AppColors.muted)),
      const SizedBox(height: 4),
      Text(tr('privacy_note'),
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(color: AppColors.muted)),
      if (_error != null) ...[
        const SizedBox(height: 16),
        _ErrorBox(message: _error!),
      ],
    ];
  }

  List<Widget> _resultView(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final r = _result;
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(_image!, height: 150, fit: BoxFit.cover),
      ),
      const SizedBox(height: 16),
      if (_loading)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(tr('analyzing'), style: text.bodyMedium),
          ]),
        ),
      if (_error != null) _ErrorBox(message: _error!),
      if (r != null) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.isDemo) ...[
                  const Pill('DEMO', background: AppColors.accentSoft, foreground: AppColors.accentText),
                  const SizedBox(height: 10),
                ],
                if (r.sender.isNotEmpty)
                  Row(children: [
                    Text(tr('from_office'),
                        style: text.labelLarge?.copyWith(color: AppColors.primary)),
                    const Spacer(),
                    Text(r.sender, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                const SizedBox(height: 10),
                Text(r.summary,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.5)),
                if (r.details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(r.details, style: text.bodyMedium?.copyWith(height: 1.7)),
                ],
              ],
            ),
          ),
        ),
        if (r.actions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('what_to_do'),
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  for (var i = 0; i < r.actions.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primarySoft,
                            child: Text('${i + 1}',
                                style: text.labelSmall?.copyWith(
                                    color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(r.actions[i], style: text.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (r.deadline != null) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => showDateEditor(
              context,
              initialTitle: r.deadlineLabel ?? r.summary,
              initialDate: r.deadline,
              initialPlace: r.sender,
            ),
            icon: const Icon(Icons.event_available_outlined),
            label: Text('${tr('add_date')} · ${formatDate(context, r.deadline!)}'),
          ),
        ],
        const SizedBox(height: 16),
        const Disclaimer(),
      ],
      if (!_loading) ...[
        const SizedBox(height: 16),
        OutlinedButton(onPressed: _reset, child: Text(tr('scan_again'))),
      ],
    ];
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.accentText, height: 1.6)),
      );
}
