import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/auth_view_model.dart';
import '../utils/app_theme.dart';
import 'feed_screen.dart';
import 'coach_screen.dart';
import 'meal_plan_screen.dart';
import 'intel_screen.dart';
import 'arena_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final AnimationController _tabAnimController;
  late final AnimationController _pageAnimController;
  int _previousTab = 0;

  final _screens = const [
    FeedScreen(),
    CoachScreen(),
    MealPlanScreen(),
    IntelScreen(),
    ArenaScreen(),
    StoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _tabAnimController.dispose();
    _pageAnimController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index, AppState appState) {
    if (index == appState.selectedTab.index) return;
    _previousTab = appState.selectedTab.index;
    _pageAnimController.value = 0;
    appState.selectedTab = AppTab.values[index];
    _pageAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          extendBody: true,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(appState),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _pageAnimController,
                      builder: (context, child) {
                        final curve = Curves.easeOutCubic;
                        final val = curve.transform(_pageAnimController.value);
                        return FadeTransition(
                          opacity: AlwaysStoppedAnimation(val),
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - val)),
                            child: IndexedStack(
                              index: appState.selectedTab.index,
                              children: _screens,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (appState.showCoinEarned) _buildCoinBanner(appState),
              Positioned(
                left: 12,
                right: 12,
                bottom: MediaQuery.of(context).padding.bottom + 8,
                child: _PremiumTabBar(
                  selectedIndex: appState.selectedTab.index,
                  onTabSelected: (i) => _onTabSelected(i, appState),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(AppState appState) {
    final auth = context.watch<AuthViewModel>();
    final userName = auth.currentUser?.name ?? 'Champion';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'V';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            Text(
              appState.selectedTab.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppTheme.goldAccent.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppTheme.goldAccent, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '${appState.vCoins}',
                    style: const TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => ProfileScreen.show(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.neonGreen,
                      AppTheme.neonGreen.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBanner(AppState appState) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: appState.showCoinEarned ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.neonGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonGreen.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.black, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appState.lastCoinReason,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumTabBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _PremiumTabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<_PremiumTabBar> createState() => _PremiumTabBarState();
}

class _PremiumTabBarState extends State<_PremiumTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  static const _tabItems = [
    _TabItem(Icons.home_rounded, 'Feed'),
    _TabItem(Icons.smart_toy_rounded, 'Coach'),
    _TabItem(Icons.restaurant_rounded, 'Meals'),
    _TabItem(Icons.insights_rounded, 'Intel'),
    _TabItem(Icons.emoji_events_rounded, 'Arena'),
    _TabItem(Icons.storefront_rounded, 'Store'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowVal = _glowController.value;
            return Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromRGBO(28, 28, 25, 0.95),
                    Color.fromRGBO(
                        28, 28 + (5 * glowVal).round(), 25, 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Color.lerp(
                    AppTheme.border.withOpacity(0.4),
                    AppTheme.neonGreen.withOpacity(0.12),
                    glowVal,
                  )!,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color:
                        AppTheme.neonGreen.withOpacity(0.04 + 0.03 * glowVal),
                    blurRadius: 30,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_tabItems.length, (index) {
              final item = _tabItems[index];
              final isSelected = index == widget.selectedIndex;
              return _TabButton(
                icon: item.icon,
                label: item.label,
                isSelected: isSelected,
                glowController: _glowController,
                onTap: () => widget.onTabSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem(this.icon, this.label);
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final AnimationController glowController;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.glowController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: glowController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: isSelected
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.neonGreen.withOpacity(
                              0.1 + 0.05 * glowController.value),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonGreen.withOpacity(
                                  0.15 + 0.1 * glowController.value),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.neonGreen
                        : AppTheme.textTertiary,
                    size: 22,
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? AppTheme.neonGreen : AppTheme.textTertiary,
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: isSelected ? 0.3 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
