import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/content.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class GuideListScreen extends StatelessWidget {
  const GuideListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final guides = ContentRepository.instance.guides;
        return Scaffold(
          appBar: AppBar(title: Text(tr('tab_guide'))),
          body: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: guides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final g = guides[i];
              final v = guideVisual(g.icon);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  minTileHeight: 72,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: v.soft, borderRadius: BorderRadius.circular(12)),
                    child: Icon(v.icon, color: v.color),
                  ),
                  title: Text(pick(g.title),
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${secondLine(g.title, g.italianName)} · ${g.steps.length} ${tr('steps')}',
                      style: text.bodySmall?.copyWith(color: AppColors.muted)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: g)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class GuideDetailScreen extends StatelessWidget {
  const GuideDetailScreen({super.key, required this.guide});
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pick(guide.title)),
            Text(secondLine(guide.title, guide.italianName),
                textDirection: secondLineDirection,
                style: text.bodySmall?.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [Pill('${guide.steps.length} ${tr('steps')}')]),
          const SizedBox(height: 20),
          for (var i = 0; i < guide.steps.length; i++)
            _StepTile(
              number: i + 1,
              step: guide.steps[i],
              isLast: i == guide.steps.length - 1,
            ),
          if (guide.checklist.isNotEmpty) _Checklist(guide: guide),
          if (guide.tip != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.accentText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(pick(guide.tip),
                        style: text.bodyMedium?.copyWith(color: AppColors.accentText, height: 1.6)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Disclaimer(),
        ],
      ),
    );
  }
}

/// "What to bring" list; ticks are saved on the phone.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.guide});
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final keys = [for (var i = 0; i < guide.checklist.length; i++) '${guide.id}:$i'];
        final done = keys.where(appState.checkedItems.contains).length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(tr('what_to_bring'),
                              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        Pill('$done / ${keys.length}',
                            background: done == keys.length
                                ? AppColors.successSoft
                                : AppColors.primarySoft,
                            foreground: done == keys.length
                                ? AppColors.success
                                : AppColors.primary),
                      ],
                    ),
                  ),
                  for (var i = 0; i < guide.checklist.length; i++)
                    CheckboxListTile(
                      value: appState.checkedItems.contains(keys[i]),
                      onChanged: (_) => appState.toggleChecked(keys[i]),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: Text(pick(guide.checklist[i]), style: text.bodyMedium),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.step, required this.isLast});
  final int number;
  final GuideStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text('$number',
                    style: text.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: const Color(0xFFD9DEE5))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pick(step.title),
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(pick(step.body),
                      style: text.bodyMedium?.copyWith(color: AppColors.muted, height: 1.6)),
                  if (step.italianTerm != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(tr('in_italian'),
                              style: text.bodySmall?.copyWith(color: AppColors.muted)),
                          const Spacer(),
                          Flexible(
                            child: Text(step.italianTerm!,
                                textDirection: TextDirection.ltr,
                                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
