import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_view_model.dart';
import '../utils/app_theme.dart';

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const _pages = [
  _OnboardingPage(
    icon: Icons.sports_cricket,
    title: 'Train Like\nThe Elite',
    subtitle:
        'AI-powered drills tailored to your skill level and playing style. Level up every session.',
  ),
  _OnboardingPage(
    icon: Icons.psychology,
    title: 'Your Personal\nAI Coach',
    subtitle:
        'Get real-time feedback on your technique, strategy tips, and personalised training plans.',
  ),
  _OnboardingPage(
    icon: Icons.emoji_events,
    title: 'Compete &\nEarn Rewards',
    subtitle:
        'Climb the global leaderboard, earn V-Coins, and unlock premium gear in the store.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<AnimationController> _iconControllers;
  late final List<Animation<double>> _iconScales;

  @override
  void initState() {
    super.initState();
    _iconControllers = List.generate(
      _pages.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _iconScales = _iconControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.elasticOut))
        .toList();
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    for (int i = 0; i < _iconControllers.length; i++) {
      if (i == page) {
        _iconControllers[i].forward(from: 0);
      } else {
        _iconControllers[i].reset();
      }
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<AuthViewModel>().completeOnboarding();
    }
  }

  void _skip() {
    context.read<AuthViewModel>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _iconScales[index],
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonGreenDim,
                          ),
                          child: Center(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.cardSurface,
                                border: Border.all(
                                  color:
                                      AppTheme.neonGreen.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                page.icon,
                                size: 44,
                                color: AppTheme.neonGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? AppTheme.neonGreen
                          : AppTheme.neonGreen.withOpacity(0.2),
                    ),
                  );
                }),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            AnimatedOpacity(
              opacity: isLast ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: TextButton(
                  onPressed: isLast ? null : _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
