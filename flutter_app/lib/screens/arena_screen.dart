import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/leaderboard_entry.dart';
import '../utils/app_theme.dart';

class ArenaScreen extends StatefulWidget {
  const ArenaScreen({super.key});

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final entries = appState.gameData.leaderboard(_selectedPeriod);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              _buildPeriodFilter(),
              const SizedBox(height: 20),

              _buildYourStatsBar(appState),
              const SizedBox(height: 24),

              if (entries.length >= 3) ...[
                _buildPodium(entries.sublist(0, 3)),
                const SizedBox(height: 24),
              ],

              const Text(
                'FULL RANKINGS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildLeaderboardRow(entry),
                ),
              ),

              const SizedBox(height: 16),
              _buildChallengeBanner(),

              const SizedBox(height: 120),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: LeaderboardPeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.neonGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    period.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildYourStatsBar(AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '#${appState.globalRank}',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'RANK',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 0.5, color: AppTheme.border),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${appState.vCoins}',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'V-COINS',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 0.5, color: AppTheme.border),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${appState.drillsCompleted}',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'DRILLS',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildPodiumCard(top3[1], 130, const Color(0xFFC0C0C0), 2)),
        const SizedBox(width: 8),
        Expanded(child: _buildPodiumCard(top3[0], 160, AppTheme.goldAccent, 1)),
        const SizedBox(width: 8),
        Expanded(child: _buildPodiumCard(top3[2], 110, const Color(0xFFCD7F32), 3)),
      ],
    );
  }

  Widget _buildPodiumCard(LeaderboardEntry entry, double height, Color medalColor, int position) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            medalColor.withOpacity(0.12),
            AppTheme.cardSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: medalColor.withOpacity(0.3),
          width: position == 1 ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: position == 1 ? 26 : 22,
                backgroundColor: medalColor.withOpacity(0.2),
                child: Text(
                  entry.playerName.isNotEmpty
                      ? entry.playerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: medalColor,
                    fontSize: position == 1 ? 20 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.cardSurface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$position',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.playerName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: AppTheme.goldAccent, size: 12),
              const SizedBox(width: 3),
              Text(
                '${entry.vCoins}',
                style: const TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry) {
    final isTop3 = entry.rank <= 3;
    final rankColor = switch (entry.rank) {
      1 => AppTheme.goldAccent,
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppTheme.textTertiary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppTheme.neonGreen.withOpacity(0.06)
            : AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppTheme.neonGreen.withOpacity(0.3)
              : AppTheme.border,
          width: entry.isCurrentUser ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isTop3
                ? Icon(Icons.emoji_events, color: rankColor, size: 20)
                : Text(
                    '${entry.rank}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          CircleAvatar(
            radius: 18,
            backgroundColor: entry.isCurrentUser
                ? AppTheme.neonGreen.withOpacity(0.15)
                : AppTheme.cardSurfaceLight,
            child: Text(
              entry.playerName.isNotEmpty
                  ? entry.playerName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: entry.isCurrentUser
                    ? AppTheme.neonGreen
                    : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.playerName,
                        style: TextStyle(
                          color: entry.isCurrentUser
                              ? AppTheme.neonGreen
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${entry.drillsCompleted} drills',
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: AppTheme.goldAccent, size: 14),
              const SizedBox(width: 4),
              Text(
                '${entry.vCoins}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          if (!entry.isCurrentUser)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreenDim,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppTheme.neonGreen.withOpacity(0.3),
                  ),
                ),
                child: Icon(Icons.bolt, color: AppTheme.neonGreen, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Challenge a friend',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              '+5 V-Coins',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
