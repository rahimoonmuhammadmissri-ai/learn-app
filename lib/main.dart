import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/launch/launch.dart';
import 'features/shell/shell.dart';

void main() => runApp(const LearnApp());

class LearnApp extends StatelessWidget {
  const LearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'Learn - Smart Study App',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: const Gate(),
      ),
    );
  }
}

/// Splash -> onboarding -> app shell.
class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  int _stage = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: switch (_stage) {
        0 => SplashScreen(key: const ValueKey(0), onDone: () => setState(() => _stage = 1)),
        1 => OnboardingScreen(key: const ValueKey(1), onFinish: () => setState(() => _stage = 2)),
        _ => const AppShell(key: ValueKey(2)),
      },
    );
  }
}
