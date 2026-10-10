import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final upcoming = appState.dates.where((d) => d.daysLeft >= 0).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(tr('my_dates')),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: IconButton.filled(
                  tooltip: tr('add_date'),
                  onPressed: () => showDateEditor(context),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionTitle(tr('upcoming')),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(tr('no_dates'),
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: AppColors.muted)),
                ),
              for (final d in upcoming) ...[
                _DateCard(date: d),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              SectionTitle(tr('reminders')),
              Card(
                child: Column(
                  children: [
                    for (final days in const [60, 30, 1])
                      SwitchListTile(
                        title: Text(tr('before_$days')),
                        value: appState.reminderOffsets.contains(days),
                        onChanged: (on) => appState.toggleReminder(days, on),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.date});
  final TrackedDate date;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final soon = date.daysLeft <= 14;
    final soft = soon ? AppColors.accentSoft : AppColors.primarySoft;
    final strong = soon ? AppColors.accentText : AppColors.primary;
    final local = MaterialLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDateEditor(context, existing: date),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 60,
                decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${date.date.day}',
                        style: text.titleLarge?.copyWith(color: strong, fontWeight: FontWeight.w700, height: 1)),
                    Text(local.formatMonthYear(date.date).split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall?.copyWith(color: strong)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date.title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    if (date.place.isNotEmpty)
                      Text(date.place, style: text.bodySmall?.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              Pill(
                date.daysLeft == 0
                    ? tr('today')
                    : '${tr('in_days')} ${date.daysLeft} ${tr('days')}',
                background: soft,
                foreground: strong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to add or edit a tracked date. Used from Home (permit),
/// the tracker screen, and the scan result (deadline found in a letter).
Future<void> showDateEditor(
  BuildContext context, {
  TrackedDate? existing,
  bool isPermit = false,
  String? initialTitle,
  DateTime? initialDate,
  String? initialPlace,
  String kind = '',
}) {
  final permit = existing?.isPermit ?? isPermit;
  final docKind = existing?.kind ?? kind;
  final titleCtrl = TextEditingController(
      text: existing?.title ?? initialTitle ?? (permit ? tr('permit_expiry') : ''));
  final placeCtrl = TextEditingController(text: existing?.place ?? initialPlace ?? '');
  DateTime? picked = existing?.date ?? initialDate;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheet) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleCtrl,
              onChanged: (_) => setSheet(() {}),
              decoration: InputDecoration(
                labelText: tr('title_label'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(picked == null ? tr('set_date') : formatDate(context, picked!)),
              onPressed: () async {
                final now = DateTime.now();
                final d = await showDatePicker(
                  context: context,
                  initialDate: picked ?? now,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 10),
                );
                if (d != null) setSheet(() => picked = d);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: placeCtrl,
              decoration: InputDecoration(
                labelText: tr('place_label'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: picked == null || titleCtrl.text.trim().isEmpty
                  ? null
                  : () async {
                      await appState.saveDate(TrackedDate(
                        id: existing?.id ?? appState.newDateId(),
                        title: titleCtrl.text.trim(),
                        date: picked!,
                        place: placeCtrl.text.trim(),
                        isPermit: permit,
                        kind: docKind,
                      ));
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
              child: Text(tr('save')),
            ),
            if (existing != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await appState.deleteDate(existing);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8E1B16)),
                child: Text(tr('delete')),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
