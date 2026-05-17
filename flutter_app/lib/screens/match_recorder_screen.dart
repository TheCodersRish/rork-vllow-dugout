import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/performance_stats.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class MatchRecorderScreen extends StatefulWidget {
  const MatchRecorderScreen({super.key});

  @override
  State<MatchRecorderScreen> createState() => _MatchRecorderScreenState();
}

class _MatchRecorderScreenState extends State<MatchRecorderScreen>
    with SingleTickerProviderStateMixin {
  final _runsController = TextEditingController();
  final _ballsController = TextEditingController();
  String _selectedOpponent = '';
  bool _isRecorded = false;
  int _coinsEarned = 0;
  late AnimationController _trophyAnimController;

  static const _opponents = [
    'Local Club XI',
    'City Warriors',
    'District Select',
    'School Team',
    'Academy XI',
    'State U-19',
    'Weekend League',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _trophyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _runsController.dispose();
    _ballsController.dispose();
    _trophyAnimController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final runs = int.tryParse(_runsController.text);
    final balls = int.tryParse(_ballsController.text);
    return runs != null && runs >= 0 && balls != null && balls > 0 && _selectedOpponent.isNotEmpty;
  }

  double get _strikeRate {
    final runs = int.tryParse(_runsController.text) ?? 0;
    final balls = int.tryParse(_ballsController.text) ?? 1;
    return balls > 0 ? (runs / balls) * 100 : 0;
  }

  void _recordMatch() {
    if (!_isValid) return;
    HapticFeedback.heavyImpact();

    final runs = int.parse(_runsController.text);
    int coins = 10;
    if (runs >= 50) coins += 25;
    if (runs >= 100) coins += 50;
    if (_strikeRate > 150) coins += 15;

    final appState = context.read<AppState>();
    final latestMatch = appState.gameData.matchHistory.isNotEmpty
        ? appState.gameData.matchHistory.first
        : null;
    final previousStrikeRate = latestMatch?.strikeRate ?? 0;
    final strikeRateChange = previousStrikeRate > 0
        ? ((_strikeRate - previousStrikeRate) / previousStrikeRate) * 100
        : 0.0;

    appState.recordMatch(
      PerformanceStats(
        runsScored: runs,
        ballsFaced: int.parse(_ballsController.text),
        strikeRateChange: strikeRateChange,
        opponent: _selectedOpponent,
        coinBonus: coins,
      ),
    );

    _trophyAnimController.forward(from: 0);
    setState(() {
      _isRecorded = true;
      _coinsEarned = coins;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isRecorded ? _buildRecordedView() : _buildFormView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 20),
              ),
            ),
          ),
          const Text(
            'RECORD MATCH',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Cricket ball icon (48pt)
          const Icon(Icons.sports_cricket, color: AppTheme.neonGreen, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Log Your Performance',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Record your match stats and earn V-Coins',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 36),
          // RUNS label (size 9 bold tracking 2)
          _buildFieldLabel('RUNS SCORED'),
          const SizedBox(height: 8),
          _buildNumberField(
            controller: _runsController,
            hint: '0',
          ),
          const SizedBox(height: 16),
          // BALLS label (size 9 bold tracking 2)
          _buildFieldLabel('BALLS FACED'),
          const SizedBox(height: 8),
          _buildNumberField(
            controller: _ballsController,
            hint: '0',
          ),
          const SizedBox(height: 24),
          _buildOpponentSelector(),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _isValid ? _recordMatch : null,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: _isValid ? AppTheme.neonGreen : AppTheme.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(29),
              ),
              alignment: Alignment.center,
              child: Text(
                'RECORD MATCH',
                style: TextStyle(
                  color: _isValid ? Colors.black : AppTheme.textTertiary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: true,
          hintStyle: const TextStyle(color: AppTheme.textTertiary),
        ),
      ),
    );
  }

  Widget _buildOpponentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OPPONENT',
          style: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _opponents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final opp = _opponents[index];
              final isSelected = opp == _selectedOpponent;
              return GestureDetector(
                onTap: () => setState(() => _selectedOpponent = opp),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.neonGreen : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(
                      color: isSelected ? AppTheme.neonGreen : AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    opp,
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordedView() {
    final runs = int.tryParse(_runsController.text) ?? 0;
    final balls = int.tryParse(_ballsController.text) ?? 1;
    final sr = _strikeRate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Trophy in double circle
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _trophyAnimController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldAccent.withOpacity(0.15),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardSurface,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.emoji_events, color: AppTheme.goldAccent, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Match Recorded!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          // "+X V-COINS" goldAccent capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(29),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppTheme.goldAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  '+$_coinsEarned V-COINS',
                  style: const TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Runs/balls/SR stat row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResultStat('$runs', 'Runs'),
              Container(width: 1, height: 40, color: AppTheme.border),
              _buildResultStat('$balls', 'Balls'),
              Container(width: 1, height: 40, color: AppTheme.border),
              _buildResultStat(sr.toStringAsFixed(1), 'SR'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'vs $_selectedOpponent',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(29),
              ),
              alignment: Alignment.center,
              child: const Text(
                'DONE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}
