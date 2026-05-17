import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/drill.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import 'dugout_hub_screen.dart';
import 'drill_session_screen.dart';
import 'skills_library_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  String _greetingMessage(int streak) {
    final hour = DateTime.now().hour;
    if (streak > 7) {
      return hour < 12
          ? 'Morning, legend.\n$streak-day streak!'
          : 'Keep grinding.\n$streak days strong!';
    } else if (streak > 0) {
      return hour < 12
          ? 'Wake up, champ.\nDay ${streak + 1} awaits.'
          : "Let's go, champ.\nTime to grind.";
    } else {
      return hour < 12
          ? "Wake up, champ.\nTime to grind."
          : "The pitch is calling.\nLet's train.";
    }
  }

  String _motivationalSubtitle(int completed) {
    if (completed == 0) {
      return 'Complete your first drill to start earning V-Coins!';
    } else if (completed < 10) {
      return '$completed drills done. The pitch is waiting for its next master.';
    } else {
      return '$completed drills crushed. Elite status incoming.';
    }
  }

  void _openDrillSession(BuildContext context, Drill drill) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DrillSessionScreen(drill: drill),
      ),
    );
  }

  void _openSkillsLibrary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const SkillsLibraryScreen(),
      ),
    );
  }

  void _openDugoutHub(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const DugoutHubScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final drills = MockData.drills;
    final dailyDrill = drills.first;
    final browseDrills = drills.sublist(1);
    final isDailyCompleted = appState.gameData.isDrillCompleted(dailyDrill.id);
    final completedCount =
        drills.where((d) => appState.gameData.isDrillCompleted(d.id)).length;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            children: [
              _buildMorningPing(appState),
              const SizedBox(height: 16),
              _buildDugoutHubCard(context),
              const SizedBox(height: 24),
              _buildSkillTipCard(context, appState, drills.first),
              const SizedBox(height: 24),
              _buildDailyMission(context, dailyDrill, isDailyCompleted),
              const SizedBox(height: 24),
              _buildStatsGlimpse(appState),
              const SizedBox(height: 24),
              _buildBrowseDrills(context, appState, browseDrills,
                  completedCount, drills.length),
              if (appState.drillsCompleted > 0) ...[
                const SizedBox(height: 24),
                _buildRecentActivity(appState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDugoutHubCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDugoutHub(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.neonGreen.withValues(alpha: 0.14),
              AppTheme.cardSurface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.dashboard_customize,
                color: AppTheme.neonGreen,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open Dugout Hub',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mental, S&C, video, community, sharing, entitlements and more.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.neonGreen),
          ],
        ),
      ),
    );
  }

  // ── Section 1: Morning Ping ──────────────────────────────────────────

  Widget _buildMorningPing(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'LIVE FROM THE COACH',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingMessage(appState.winStreak),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _motivationalSubtitle(appState.drillsCompleted),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section 2: Skill Tip Card (Hero) ─────────────────────────────────

  Widget _buildSkillTipCard(
      BuildContext context, AppState appState, Drill drill) {
    final isBookmarked = appState.isBookmarked(drill.id);
    final isCompleted = appState.gameData.isDrillCompleted(drill.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: drill.imageURL,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppTheme.cardSurface),
              errorWidget: (_, __, ___) =>
                  Container(color: AppTheme.cardSurface),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.2, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.white.withOpacity(0.15),
                    child: Text(
                      drill.category.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => appState.toggleBookmark(drill.id),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.white.withOpacity(0.1),
                      alignment: Alignment.center,
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: isBookmarked ? AppTheme.neonGreen : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    drill.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    drill.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openDrillSession(context, drill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow,
                                  size: 14, color: Colors.black),
                              const SizedBox(width: 6),
                              Text(
                                isCompleted ? 'REDO DRILL' : 'WATCH DRILL',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        drill.durationFormatted,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 3: Daily Mission ─────────────────────────────────────────

  Widget _buildDailyMission(BuildContext context, Drill drill, bool completed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY MISSION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      drill.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 16, color: AppTheme.goldAccent),
                    const SizedBox(width: 6),
                    Text(
                      '+${drill.coinReward * 2}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatPill('TARGET', '${drill.targetHits} Hits'),
              const SizedBox(width: 10),
              _buildStatPill('TIME', '${drill.durationSeconds}s'),
              const SizedBox(width: 10),
              _buildStatPill('DIFFICULTY', drill.difficulty.displayName),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: completed ? null : () => _openDrillSession(context, drill),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: completed
                    ? AppTheme.neonGreen.withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: completed
                      ? AppTheme.neonGreen.withOpacity(0.3)
                      : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: completed
                    ? [
                        const Icon(Icons.check_circle,
                            size: 16, color: AppTheme.neonGreen),
                        const SizedBox(width: 10),
                        const Text(
                          'MISSION COMPLETE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                      ]
                    : [
                        const Text(
                          'START TRACKING SESSION',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.sensors,
                            size: 16, color: AppTheme.neonGreen),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 4: Stats Glimpse ─────────────────────────────────────────

  Widget _buildStatsGlimpse(AppState appState) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => appState.selectedTab = AppTab.intel,
            child: _buildStatCard(
              icon: Icons.north_east,
              iconBg: AppTheme.neonGreenDim,
              label: 'WIN STREAK',
              value: '${appState.winStreak} DAYS',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => appState.selectedTab = AppTab.arena,
            child: _buildStatCard(
              icon: Icons.military_tech,
              iconBg: Colors.orange.withOpacity(0.15),
              label: 'GLOBAL RANK',
              value: '#${appState.globalRank}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 5: Browse Drills ─────────────────────────────────────────

  Widget _buildBrowseDrills(BuildContext context, AppState appState,
      List<Drill> drills, int completedCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'MORE DRILLS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount/$totalCount DONE',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppTheme.neonGreen,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _openSkillsLibrary(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.neonGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Text(
                    'BROWSE ALL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: AppTheme.neonGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          for (final drill in drills) ...[
            const SizedBox(height: 14),
            _buildDrillRow(context, appState, drill),
          ],
        ],
      ),
    );
  }

  Widget _buildDrillRow(BuildContext context, AppState appState, Drill drill) {
    final completed = appState.gameData.isDrillCompleted(drill.id);

    return GestureDetector(
      onTap: () => _openDrillSession(context, drill),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: completed
              ? AppTheme.neonGreen.withOpacity(0.04)
              : AppTheme.cardSurfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? AppTheme.neonGreen.withOpacity(0.15)
                    : AppTheme.cardSurfaceLight,
              ),
              alignment: Alignment.center,
              child: Icon(
                completed ? Icons.check : Icons.play_arrow,
                size: 14,
                color: completed ? AppTheme.neonGreen : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drill.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        drill.category.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('•',
                            style: TextStyle(color: AppTheme.textTertiary)),
                      ),
                      Text(
                        drill.difficulty.displayName,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 10, color: AppTheme.goldAccent),
                    const SizedBox(width: 4),
                    Text(
                      '+${drill.coinReward}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  drill.durationFormatted,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 6: Recent Activity ───────────────────────────────────────

  Widget _buildRecentActivity(AppState appState) {
    final transactions =
        appState.gameData.recentCoinTransactions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppTheme.textSecondary,
            ),
          ),
          for (final tx in transactions) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.neonGreen.withOpacity(0.15),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.star,
                        size: 12, color: AppTheme.neonGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.reason,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat.yMMMd().add_jm().format(tx.date),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${tx.amount}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.neonGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
