import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.fromLTRB(Sp.m, 0, Sp.m, Sp.l), children: [
        const SectionHeader('Theme', subtitle: 'Applies right away. Not saved after you close the app yet.'),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) => SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_android_rounded)),
              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
            ],
            selected: {mode},
            onSelectionChanged: (s) => themeModeNotifier.value = s.first,
          ),
        ),
        const SectionHeader('Language'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.check_circle_rounded, color: cs.primary),
          title: const Text('English'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: false,
          leading: Icon(Icons.radio_button_unchecked_rounded),
          title: Text('Roman Urdu'),
          subtitle: Text('Coming later'),
        ),
        const SectionHeader('About'),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.info_outline_rounded),
          title: Text('Learn - Smart Study App'),
          subtitle: Text('Version 0.1.0 - Phase 1 (design and navigation)'),
        ),
      ]),
    );
  }
}
