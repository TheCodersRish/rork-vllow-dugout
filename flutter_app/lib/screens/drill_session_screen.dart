import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/drill.dart';
import '../utils/app_theme.dart';

class DrillTip {
  final String text;
  final DrillCategory category;
  const DrillTip(this.text, this.category);
}

const List<DrillTip> _allTips = [
  DrillTip('Watch the ball right onto the bat face.', DrillCategory.batting),
  DrillTip('Keep your head still and eyes level through the shot.', DrillCategory.batting),
  DrillTip('Transfer weight forward on front-foot drives.', DrillCategory.batting),
  DrillTip('Play the ball under your eyes — don\'t reach.', DrillCategory.batting),
  DrillTip('Rotate strike to keep the scoreboard ticking.', DrillCategory.batting),
  DrillTip('Follow through fully — let your arm finish high.', DrillCategory.bowling),
  DrillTip('Hit the seam consistently for natural movement.', DrillCategory.bowling),
  DrillTip('Bowl to a plan — set up the batsman over multiple deliveries.', DrillCategory.bowling),
  DrillTip('Use the crease width to change the angle of delivery.', DrillCategory.bowling),
  DrillTip('Load up with a strong core and drive from your legs.', DrillCategory.bowling),
  DrillTip('Attack the ball — don\'t wait for it to come to you.', DrillCategory.fielding),
  DrillTip('Keep your body behind the ball; soft hands for catching.', DrillCategory.fielding),
  DrillTip('Always back up the stumps; anticipate the throw.', DrillCategory.fielding),
  DrillTip('Move early and get low for ground balls.', DrillCategory.fielding),
  DrillTip('Use a crow-hop for long throws to maintain accuracy.', DrillCategory.fielding),
  DrillTip('Stay low; rise with the ball for takes above stumps.', DrillCategory.wicketkeeping),
  DrillTip('Give with the hands — cushion the ball on takes.', DrillCategory.wicketkeeping),
  DrillTip('Watch the ball off the pitch, not the batsman\'s shot.', DrillCategory.wicketkeeping),
  DrillTip('Move laterally in small steps — don\'t dive unless forced.', DrillCategory.wicketkeeping),
  DrillTip('Call loudly for catches; own the area behind the stumps.', DrillCategory.wicketkeeping),
];

enum SessionPhase { preSession, countdown, active, completed }

class DrillSessionScreen extends StatefulWidget {
  final Drill drill;

  const DrillSessionScreen({super.key, required this.drill});

  @override
  State<DrillSessionScreen> createState() => _DrillSessionScreenState();
}

class _DrillSessionScreenState extends State<DrillSessionScreen>
    with TickerProviderStateMixin {
  SessionPhase _phase = SessionPhase.preSession;
  int _countdownValue = 3;
  int _remainingSeconds = 0;
  int _hitCount = 0;
  int _currentTipIndex = 0;
  Timer? _sessionTimer;
  Timer? _tipRotationTimer;
  late AnimationController _countdownAnimController;
  late AnimationController _completionAnimController;
  late List<DrillTip> _tips;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.drill.durationSeconds;
    _tips = _allTips.where((t) => t.category == widget.drill.category).toList();
    if (_tips.isEmpty) _tips = _allTips.take(5).toList();

    _countdownAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _completionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _tipRotationTimer?.cancel();
    _countdownAnimController.dispose();
    _completionAnimController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _phase = SessionPhase.countdown;
      _countdownValue = 3;
    });
    _countdownAnimController.forward(from: 0);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue <= 1) {
        timer.cancel();
        _startSession();
      } else {
        setState(() => _countdownValue--);
        _countdownAnimController.forward(from: 0);
      }
    });
  }

  void _startSession() {
    setState(() {
      _phase = SessionPhase.active;
      _remainingSeconds = widget.drill.durationSeconds;
      _hitCount = 0;
    });

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _completeSession();
      } else {
        setState(() => _remainingSeconds--);
      }
    });

    _tipRotationTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() => _currentTipIndex = (_currentTipIndex + 1) % _tips.length);
    });
  }

  void _completeSession() {
    _sessionTimer?.cancel();
    _tipRotationTimer?.cancel();
    HapticFeedback.heavyImpact();
    _completionAnimController.forward(from: 0);

    final appState = context.read<AppState>();
    appState.earnCoinsWithFeedback(widget.drill.coinReward, 'Drill completed');

    setState(() => _phase = SessionPhase.completed);
  }

  void _onHitTap() {
    if (_phase != SessionPhase.active) return;
    HapticFeedback.lightImpact();
    setState(() => _hitCount++);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildPhaseContent()),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Text(
              widget.drill.category.displayName.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case SessionPhase.preSession:
        return _buildPreSession();
      case SessionPhase.countdown:
        return _buildCountdown();
      case SessionPhase.active:
        return _buildActiveSession();
      case SessionPhase.completed:
        return _buildCompletion();
    }
  }

  Widget _buildPreSession() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            widget.drill.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            widget.drill.subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Timer circle: 180x180, 10px stroke, cardSurfaceLight bg
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    backgroundColor: AppTheme.cardSurfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cardSurfaceLight),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(widget.drill.durationSeconds),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'READY',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 3 stat pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatPill(Icons.touch_app, '${widget.drill.targetHits}', 'Target'),
              _buildStatPill(Icons.timer, widget.drill.durationFormatted, 'Duration'),
              _buildStatPill(Icons.monetization_on, '+${widget.drill.coinReward}', 'Reward'),
            ],
          ),
          const SizedBox(height: 32),
          // Coach tip with brain icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: AppTheme.goldAccent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COACH TIP',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tips.isNotEmpty ? _tips[0].text : 'Focus on technique over speed.',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Center(
      child: AnimatedBuilder(
        animation: _countdownAnimController,
        builder: (context, child) {
          final scale = 1.0 + (1.0 - _countdownAnimController.value) * 0.5;
          final opacity = _countdownAnimController.value;
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neonGreen, width: 6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$_countdownValue',
                  style: const TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveSession() {
    final total = widget.drill.durationSeconds;
    final progress = total > 0 ? _remainingSeconds / total : 0.0;

    return GestureDetector(
      onTap: _onHitTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress timer 180x180
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: AppTheme.cardSurfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Hits counter
          Text(
            '$_hitCount',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'HITS',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          // Rotating tips with "STEP X/Y" labels
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(_currentTipIndex),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP ${_currentTipIndex + 1}/${_tips.length}',
                    style: const TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: AppTheme.goldAccent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _tips[_currentTipIndex % _tips.length].text,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _completionAnimController,
              curve: Curves.elasticOut,
            ),
            // Double circle: 140 outer neonGreenDim, 110 inner cardSurface
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonGreenDim,
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
                child: const Icon(
                  Icons.check,
                  color: AppTheme.neonGreen,
                  size: 44,
                  weight: 700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'SESSION COMPLETE!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // "+X V-COINS EARNED" goldAccent capsule
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
                  '+${widget.drill.coinReward} V-COINS EARNED',
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
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatPill(Icons.touch_app, '$_hitCount', 'Hits'),
              _buildStatPill(
                Icons.timer,
                _formatTime(widget.drill.durationSeconds),
                'Duration',
              ),
              _buildStatPill(
                Icons.speed,
                widget.drill.targetHits > 0
                    ? '${((_hitCount / widget.drill.targetHits) * 100).toInt()}%'
                    : '—',
                'Accuracy',
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Post-session insight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.neonGreen.withOpacity(0.08),
                  AppTheme.cardSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.neonGreen.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.neonGreen, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _hitCount >= widget.drill.targetHits
                        ? 'Outstanding session! You exceeded your target. Your consistency is improving — keep pushing.'
                        : 'Good effort! You\'re building muscle memory. Focus on clean repetitions next time.',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Icon(icon, color: AppTheme.neonGreen, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildActionButtons(),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    switch (_phase) {
      case SessionPhase.preSession:
        return [
          // "START SESSION" neonGreen pill
          GestureDetector(
            onTap: _startCountdown,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(29),
              ),
              alignment: Alignment.center,
              child: const Text(
                'START SESSION',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // "RECORD WITH CAMERA" outlined pill
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(29),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.videocam_outlined, color: AppTheme.textSecondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'RECORD WITH CAMERA',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      case SessionPhase.countdown:
        return [const SizedBox.shrink()];
      case SessionPhase.active:
        return [
          // "TAP TO HIT" neonGreen button
          GestureDetector(
            onTap: _onHitTap,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(29),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.touch_app, color: Colors.black, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'TAP TO HIT',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      case SessionPhase.completed:
        return [
          // "BACK TO FEED" neonGreen pill
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
                'BACK TO FEED',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ];
    }
  }
}
