import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'tracker_screen.dart';

Future<void> openExternal(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

// ---------------------------------------------------------------------------
// Permit status: explains where the number is and opens the official site.
// ---------------------------------------------------------------------------
class PermitStatusScreen extends StatelessWidget {
  const PermitStatusScreen({super.key});

  static const officialUrl = 'https://questure.poliziadistato.it/stranieri';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr('tool_status'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tr('status_intro'), style: text.titleMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(tr('status_where_code'),
                        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  Text(tr('status_code_help'), style: text.bodyMedium?.copyWith(height: 1.7)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: accentButtonStyle(context),
            onPressed: () => openExternal(officialUrl),
            icon: const Icon(Icons.open_in_new),
            label: Text(tr('open_official_site')),
          ),
          const SizedBox(height: 8),
          Text('questure.poliziadistato.it',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: text.bodySmall?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Offices nearby: opens the phone's map app with a search near the user.
// ---------------------------------------------------------------------------
class OfficesScreen extends StatelessWidget {
  const OfficesScreen({super.key});

  static const _offices = [
    ('office_patronato', 'Patronato CAF', Icons.support_agent),
    ('office_questura', 'Questura ufficio immigrazione', Icons.local_police_outlined),
    ('office_post', 'Poste Italiane Sportello Amico', Icons.local_post_office_outlined),
    ('office_asl', 'ASL anagrafe sanitaria', Icons.local_hospital_outlined),
    ('office_comune', 'Comune ufficio anagrafe', Icons.account_balance_outlined),
    ('office_entrate', 'Agenzia delle Entrate', Icons.receipt_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr('tool_offices'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tr('offices_intro'), style: text.bodyLarge?.copyWith(height: 1.6)),
          const SizedBox(height: 16),
          for (final (key, query, icon) in _offices) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                minTileHeight: 64,
                leading: Icon(icon, color: AppColors.primary),
                title: Text(tr(key), style: text.titleSmall),
                trailing: const Icon(Icons.map_outlined, color: AppColors.muted),
                onTap: () => openExternal(
                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My documents: expiry dates of the user's documents, with reminders.
// ---------------------------------------------------------------------------
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _docs = [
    ('passport', 'doc_passport', Icons.book_outlined),
    ('id', 'doc_id', Icons.badge_outlined),
    ('licence', 'doc_licence', Icons.directions_car_outlined),
    ('health', 'doc_health', Icons.favorite_border),
    ('isee', 'doc_isee', Icons.euro_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final permit = appState.permit;
        return Scaffold(
          appBar: AppBar(title: Text(tr('tool_wallet'))),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(tr('wallet_intro'), style: text.bodyLarge?.copyWith(height: 1.6)),
              const SizedBox(height: 16),
              _DocRow(
                icon: Icons.credit_card,
                title: tr('your_permit'),
                date: permit,
                onTap: () => showDateEditor(context, existing: permit, isPermit: true),
              ),
              for (final (kind, key, icon) in _docs)
                _DocRow(
                  icon: icon,
                  title: tr(key),
                  date: appState.dateOfKind(kind),
                  onTap: () => showDateEditor(
                    context,
                    existing: appState.dateOfKind(kind),
                    kind: kind,
                    initialTitle: tr(key),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.icon, required this.title, required this.date, required this.onTap});
  final IconData icon;
  final String title;
  final TrackedDate? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final d = date;
    final soon = d != null && d.daysLeft <= 60;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          minTileHeight: 68,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(
            d == null ? tr('not_set') : '${tr('expires_on')} ${formatDate(context, d.date)}',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
          trailing: d == null
              ? const Icon(Icons.add_circle_outline, color: AppColors.primary)
              : Pill(
                  d.daysLeft < 0 ? tr('expired') : '${d.daysLeft} ${tr('days')}',
                  background: soon ? AppColors.accentSoft : AppColors.primarySoft,
                  foreground: soon ? AppColors.accentText : AppColors.primary,
                ),
          onTap: onTap,
        ),
      ),
    );
  }
}
