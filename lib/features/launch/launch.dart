import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onDone();
        });
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navy, AppColors.violet]),
        ),
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: .8, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.school_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: Sp.m),
                const Text('Learn', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Smart Study App', style: TextStyle(color: AppColors.teal, fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _i = 0;

  static const _pages = [
    (Icons.menu_book_rounded, 'Books for every class', 'Browse textbooks by board, class and subject.'),
    (Icons.auto_awesome_rounded, 'AI study tools', 'Turn your topics into MCQs and clear notes.'),
    (Icons.insights_rounded, 'Practice and revise', 'Tests and revision tools, added step by step.'),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final last = _i == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: widget.onFinish, child: const Text('Skip')),
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              onPageChanged: (v) => setState(() => _i = v),
              children: [
                for (final p in _pages)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(color: cs.primary.withValues(alpha: .14), shape: BoxShape.circle),
                        child: Icon(p.$1, size: 56, color: cs.primary),
                      ),
                      const SizedBox(height: 32),
                      Text(p.$2, textAlign: TextAlign.center, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text(p.$3, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    ]),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sp.l),
            child: Row(children: [
              for (var k = 0; k < _pages.length; k++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 6),
                  width: k == _i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: k == _i ? cs.primary : cs.outlineVariant, borderRadius: BorderRadius.circular(8)),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () => last
                    ? widget.onFinish()
                    : _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                child: Text(last ? 'Get started' : 'Next'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
