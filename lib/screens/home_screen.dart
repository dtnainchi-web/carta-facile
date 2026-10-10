import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/content.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../widgets/ad_banner.dart';
import '../widgets/common.dart';
import 'guide_screens.dart';
import 'letter_screen.dart';
import 'settings_screens.dart';
import 'tools_screens.dart';
import 'shell.dart';
import 'tracker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: appState, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final guides = ContentRepository.instance.guides;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('welcome'),
                              style: text.bodyMedium?.copyWith(color: AppColors.muted)),
                          Text('Carta Facile',
                              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showLanguagePicker(context),
                      icon: const Icon(Icons.language, color: AppColors.primary, size: 20),
                      label: Text(languageNames[appState.language]!),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: tr('settings'),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.line),
                        minimumSize: const Size(44, 44),
                      ),
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _PermitCard(),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: accentButtonStyle(context),
                  onPressed: () => currentTab.value = Tabs.scan,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: Text(tr('scan_cta')),
                ),
                const SizedBox(height: 12),
                SectionTitle(tr('tools')),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: [
                    _ToolTile(
                        icon: Icons.fact_check_outlined,
                        label: tr('tool_status'),
                        page: const PermitStatusScreen()),
                    _ToolTile(
                        icon: Icons.edit_note,
                        label: tr('tool_letter'),
                        page: const LetterScreen()),
                    _ToolTile(
                        icon: Icons.place_outlined,
                        label: tr('tool_offices'),
                        page: const OfficesScreen()),
                    _ToolTile(
                        icon: Icons.folder_shared_outlined,
                        label: tr('tool_wallet'),
                        page: const WalletScreen()),
                  ],
                ),
                const SizedBox(height: 12),
                SectionTitle(tr('documents')),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [for (final g in guides) _GuideTile(guide: g)],
                ),
              ],
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

class _PermitCard extends StatelessWidget {
  const _PermitCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final permit = appState.permit;

    void openEditor() => showDateEditor(context, existing: permit, isPermit: true);

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: openEditor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: permit == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('your_permit'),
                        style: text.bodyMedium?.copyWith(color: const Color(0xFFC9D8E8))),
                    const SizedBox(height: 8),
                    Text(tr('add_permit_date'),
                        style: text.titleMedium?.copyWith(color: Colors.white, height: 1.5)),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: openEditor,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.ink,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(tr('set_date')),
                    ),
                  ],
                )
              : _PermitCountdown(permit: permit),
        ),
      ),
    );
  }
}

class _PermitCountdown extends StatelessWidget {
  const _PermitCountdown({required this.permit});
  final TrackedDate permit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final days = permit.daysLeft;
    // Progress bar: full year = empty bar, close to expiry = full bar.
    final progress = (1 - days / 365).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(tr('your_permit'),
                  style: text.bodyMedium?.copyWith(color: const Color(0xFFC9D8E8))),
            ),
            if (days < 0)
              Pill(tr('expired'), background: const Color(0xFFFDE2E1), foreground: const Color(0xFF8E1B16))
            else if (days <= 90)
              Pill(tr('renew_soon'), background: AppColors.accent, foreground: AppColors.ink),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('${days < 0 ? 0 : days}',
                style: text.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text(tr('days_left'), style: text.titleMedium?.copyWith(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF34668F),
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 10),
        Text('${tr('expires_on')} ${formatDate(context, permit.date)}',
            style: text.bodySmall?.copyWith(color: const Color(0xFFC9D8E8))),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.icon, required this.label, required this.page});
  final IconData icon;
  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.guide});
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final v = guideVisual(guide.icon);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: guide)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: v.soft, borderRadius: BorderRadius.circular(12)),
                child: Icon(v.icon, color: v.color, size: 22),
              ),
              const Spacer(),
              Text(pick(guide.title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(secondLine(guide.title, guide.italianName),
                  textDirection: secondLineDirection,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
