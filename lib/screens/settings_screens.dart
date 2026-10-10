import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/config.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'tools_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('delete_data')),
        content: Text(tr('delete_data_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF8E1B16)),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
    if (ok == true) {
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      currentTab.value = Tabs.home;
      await appState.deleteAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        return Scaffold(
          appBar: AppBar(title: Text(tr('settings'))),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionTitle(tr('app_language')),
              Card(
                child: Column(
                  children: [
                    for (final code in supportedLanguages)
                      ListTile(
                        minTileHeight: 52,
                        title: Text(languageNames[code]!),
                        trailing: appState.language == code
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () => appState.setLanguage(code),
                      ),
                  ],
                ),
              ),
              if (appState.language == 'it') ...[
                const SizedBox(height: 16),
                const HelpLanguagePicker(),
              ],
              const SizedBox(height: 16),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  minTileHeight: 60,
                  leading: const Icon(Icons.workspace_premium_outlined, color: AppColors.accentText),
                  title: Text(tr('premium')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(tr('privacy_policy')),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => openExternal('${AppLinks.privacy}#${appState.language}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(tr('help_support')),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => openExternal('${AppLinks.support}#${appState.language}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(tr('version')),
                      trailing: Text(appVersion, style: text.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone_iphone, size: 18, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tr('data_on_phone'),
                        style: text.bodySmall?.copyWith(color: AppColors.muted)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _confirmDelete(context),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8E1B16)),
                icon: const Icon(Icons.delete_outline),
                label: Text(tr('delete_data')),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Premium plan. Payments arrive with the App Store version; for now the
/// button is disabled and says "coming soon".
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const benefits = [
      (Icons.document_scanner_outlined, 'premium_b1'),
      (Icons.edit_note, 'premium_b2'),
      (Icons.block, 'premium_b3'),
      (Icons.favorite_border, 'premium_b4'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(tr('premium'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: AppColors.accent, size: 48),
                const SizedBox(height: 12),
                Text(tr('premium_title'),
                    textAlign: TextAlign.center,
                    style: text.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final (icon, key) in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: AppColors.accentText, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(tr(key), style: text.titleSmall)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: null,
            style: accentButtonStyle(context),
            child: Text(tr('coming_soon')),
          ),
        ],
      ),
    );
  }
}

/// Box shown when a free monthly limit is reached, with a link to Premium.
class LimitReachedBox extends StatelessWidget {
  const LimitReachedBox({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: text.bodyMedium?.copyWith(color: AppColors.accentText, height: 1.6)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
            icon: const Icon(Icons.workspace_premium_outlined),
            label: Text(tr('see_premium')),
          ),
        ],
      ),
    );
  }
}
