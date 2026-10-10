import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import 'guide_screens.dart';
import 'home_screen.dart';
import 'lessons_screens.dart';
import 'onboarding_screen.dart';
import 'scan_screen.dart';
import 'tracker_screen.dart';

/// Current bottom tab; screens can switch tabs (e.g. Home → Scan).
final currentTab = ValueNotifier<int>(0);

class Tabs {
  static const home = 0, guide = 1, scan = 2, lessons = 3, tracker = 4;
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild on tab change and on language change.
    return ListenableBuilder(
      listenable: Listenable.merge([currentTab, appState]),
      builder: (context, _) => _build(context, currentTab.value),
    );
  }

  Widget _build(BuildContext context, int index) {
    if (!appState.onboarded) return const OnboardingScreen();
    return Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            HomeScreen(),
            GuideListScreen(),
            ScanScreen(),
            LessonsScreen(),
            TrackerScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => currentTab.value = i,
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: tr('tab_home')),
            NavigationDestination(
                icon: const Icon(Icons.description_outlined),
                selectedIcon: const Icon(Icons.description),
                label: tr('tab_guide')),
            NavigationDestination(
                icon: const Icon(Icons.document_scanner_outlined),
                selectedIcon: const Icon(Icons.document_scanner),
                label: tr('tab_scan')),
            NavigationDestination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school),
                label: tr('tab_lessons')),
            NavigationDestination(
                icon: const Icon(Icons.event_outlined),
                selectedIcon: const Icon(Icons.event),
                label: tr('tab_tracker')),
          ],
        ),
    );
  }
}
