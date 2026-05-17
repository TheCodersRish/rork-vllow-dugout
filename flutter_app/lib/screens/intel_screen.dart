import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/performance_stats.dart';
import '../utils/app_theme.dart';

class IntelScreen extends StatelessWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final matchHistory = appState.gameData.matchHistory;
    final scoringZones = appState.gameData.scoringZones;
    final dismissals = appState.gameData.dismissalPatterns;
    final latestMatch = matchHistory.isNotEmpty ? matchHistory.first : null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              if (latestMatch != null) ...[
                _LatestMatchHero(stats: latestMatch),
                const SizedBox(height: 24),
              ],

              if (matchHistory.isEmpty) ...[
                _EmptyState(),
              ] else ...[
                const _SectionLabel(text: 'SCORING HEAT MAP'),
                const SizedBox(height: 12),
                _HeatMapCard(zones: scoringZones),
                const SizedBox(height: 24),

                if (dismissals.isNotEmpty) ...[
                  const _SectionLabel(text: 'DISMISSAL PATTERN'),
                  const SizedBox(height: 12),
                  _DismissalDonut(patterns: dismissals),
                  const SizedBox(height: 24),
                ],

                _AiInsightStrip(
                  insight: latestMatch != null
                      ? _getInsight(latestMatch)
                      : 'Play more matches to unlock AI insights.',
                ),
                const SizedBox(height: 24),

                const _SectionLabel(text: 'MATCH HISTORY'),
                const SizedBox(height: 12),
                ...matchHistory.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MatchHistoryItem(stats: m),
                  ),
                ),
              ],
              const SizedBox(height: 120),
            ]),
          ),
        ),
      ],
    );
  }

  static String _getInsight(PerformanceStats stats) {
    if (stats.strikeRateChange > 5) {
      return 'Your strike rate is up ${stats.strikeRateChange.toStringAsFixed(1)}% — aggressive intent is paying off!';
    }
    if (stats.strikeRateChange < -5) {
      return 'Strike rate dipped ${stats.strikeRateChange.abs().toStringAsFixed(1)}%. Consider rotating strike earlier.';
    }
    return 'Consistent performance. Focus on converting starts into big scores.';
  }
}

class _LatestMatchHero extends StatelessWidget {
  final PerformanceStats stats;

  const _LatestMatchHero({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isPositive = stats.strikeRateChange >= 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.neonGreen.withOpacity(0.1),
            AppTheme.cardSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'LATEST PERFORMANCE',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${stats.runsScored}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'off ${stats.ballsFaced}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppTheme.neonGreen.withOpacity(0.12)
                      : Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? AppTheme.neonGreen : Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${stats.strikeRateChange.toStringAsFixed(1)}% SR',
                      style: TextStyle(
                        color: isPositive ? AppTheme.neonGreen : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'vs ${stats.opponent}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppTheme.goldAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  '+${stats.coinBonus} V-Coins earned',
                  style: const TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatMapCard extends StatelessWidget {
  final List<ScoringZone> zones;

  const _HeatMapCard({required this.zones});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: CustomPaint(
          painter: _FieldHeatPainter(zones: zones),
        ),
      ),
    );
  }
}

class _FieldHeatPainter extends CustomPainter {
  final List<ScoringZone> zones;

  _FieldHeatPainter({required this.zones});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width * 0.45;
    final ry = size.height * 0.45;

    final outlinePaint = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      outlinePaint,
    );

    final pitchPaint = Paint()
      ..color = AppTheme.cardSurfaceLight
      ..style = PaintingStyle.fill;
    final pitchRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.06,
      height: size.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitchRect, const Radius.circular(3)),
      pitchPaint,
    );

    for (final zone in zones) {
      final zx = center.dx + zone.xPosition * rx;
      final zy = center.dy + zone.yPosition * ry;
      final radius = 18.0 + zone.intensity * 24.0;

      final gradient = RadialGradient(
        colors: [
          AppTheme.neonGreen.withOpacity(zone.intensity * 0.7),
          AppTheme.neonGreen.withOpacity(0),
        ],
      );
      final zonePaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(zx, zy), radius: radius),
        );
      canvas.drawCircle(Offset(zx, zy), radius, zonePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: zone.name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(zx - textPainter.width / 2, zy + radius * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FieldHeatPainter oldDelegate) =>
      zones != oldDelegate.zones;
}

class _DismissalDonut extends StatelessWidget {
  final List<DismissalPattern> patterns;

  const _DismissalDonut({required this.patterns});

  static const _colors = [
    AppTheme.neonGreen,
    Color(0xFFFFA726),
    Color(0xFF42A5F5),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryPattern = patterns.isNotEmpty ? patterns.first : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _DonutPainter(patterns: patterns, colors: _colors),
                ),
                if (primaryPattern != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PRIMARY',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        primaryPattern.type.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(patterns.length, (i) {
                final p = patterns[i];
                final color = _colors[i % _colors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.type,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${p.percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DismissalPattern> patterns;
  final List<Color> colors;

  _DonutPainter({required this.patterns, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    var startAngle = -math.pi / 2;
    for (int i = 0; i < patterns.length; i++) {
      final sweepAngle = (patterns[i].percentage / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      patterns != old.patterns;
}

class _AiInsightStrip extends StatelessWidget {
  final String insight;

  const _AiInsightStrip({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neonGreen, width: 1.5),
            ),
            child: const Icon(Icons.psychology, color: AppTheme.neonGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERFORMANCE INTEL',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchHistoryItem extends StatelessWidget {
  final PerformanceStats stats;

  const _MatchHistoryItem({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${stats.runsScored}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${stats.ballsFaced})',
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'vs ${stats.opponent}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SR ${stats.strikeRate.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: AppTheme.goldAccent, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '+${stats.coinBonus}',
                      style: const TextStyle(
                        color: AppTheme.goldAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.neonGreenDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart,
                color: AppTheme.neonGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Matches Recorded',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Record your first match to unlock\nperformance analytics and AI insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Record Match',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
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

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}
