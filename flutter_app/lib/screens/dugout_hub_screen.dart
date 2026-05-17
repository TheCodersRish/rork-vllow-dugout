import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/local_modules.dart';
import '../providers/app_state.dart';
import '../providers/local_modules_view_model.dart';
import '../providers/player_profile_view_model.dart';
import '../utils/app_theme.dart';

class DugoutHubScreen extends StatefulWidget {
  const DugoutHubScreen({super.key});

  @override
  State<DugoutHubScreen> createState() => _DugoutHubScreenState();
}

class _DugoutHubScreenState extends State<DugoutHubScreen> {
  final _journalController = TextEditingController();
  final _mealController = TextEditingController();
  final _videoController = TextEditingController();
  final _reviewNotesController = TextEditingController();
  final _communityController = TextEditingController();
  final _captionController =
      TextEditingController(text: 'Another day, another Vllow session.');
  int _mood = 7;
  int _focus = 7;
  int _confidence = 7;
  ConditioningCategory _conditioningCategory = ConditioningCategory.power;
  int _effort = 7;
  bool _niggle = false;
  String _mealContext = 'Training day';
  String _videoTag = 'Batting';
  String _coachName = 'Coach Maya';
  String _reviewTier = 'Standard';
  String _shareFormat = 'Story 9:16';
  bool _includeStats = true;

  @override
  void dispose() {
    _journalController.dispose();
    _mealController.dispose();
    _videoController.dispose();
    _reviewNotesController.dispose();
    _communityController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modules = context.watch<LocalModulesViewModel>();
    final appState = context.watch<AppState>();
    final profile = context.watch<PlayerProfileViewModel>().profile;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildOverview(appState, modules, profile.isYouthMode),
                  const SizedBox(height: 16),
                  _buildMentalSection(modules, appState),
                  _buildConditioningSection(modules, appState),
                  _buildNutritionSection(modules, appState),
                  _buildGamificationSection(modules, appState),
                  _buildVideoSection(modules, appState),
                  _buildCoachReviewSection(
                      modules, appState, profile.isYouthMode),
                  _buildCommunitySection(
                      modules, appState, profile.isYouthMode),
                  _buildSharingSection(modules, appState, profile.isYouthMode),
                  _buildEntitlementSection(modules),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
            child:
                const Icon(Icons.close, color: AppTheme.textPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dugout Hub',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Local-first modules while backend services come online.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverview(
    AppState appState,
    LocalModulesViewModel modules,
    bool isYouthMode,
  ) {
    return _ModuleCard(
      title: 'Execution snapshot',
      subtitle:
          '${modules.trialDaysRemaining} trial days left • ${modules.selectedTier.displayName}',
      icon: Icons.dashboard_customize,
      child: Column(
        children: [
          Row(
            children: [
              _MetricTile(
                label: 'Tier',
                value: modules.tierForCoins(appState.vCoins),
                color: AppTheme.goldAccent,
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'Badges',
                value: '${modules.unlockedBadges.length}',
                color: AppTheme.neonGreen,
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'Youth',
                value: isYouthMode ? 'On' : 'Off',
                color: isYouthMode ? AppTheme.goldAccent : Colors.blueAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'No auth, CricClubs, payments, uploads, or external AI calls are used here; these are persisted Flutter foundations.',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalSection(
    LocalModulesViewModel modules,
    AppState appState,
  ) {
    return _ModuleCard(
      title: 'Mental Performance',
      subtitle: modules.mentalInsight,
      icon: Icons.psychology,
      child: Column(
        children: [
          _SliderRow(
              label: 'Mood',
              value: _mood,
              onChanged: (v) => setState(() => _mood = v)),
          _SliderRow(
              label: 'Focus',
              value: _focus,
              onChanged: (v) => setState(() => _focus = v)),
          _SliderRow(
            label: 'Confidence',
            value: _confidence,
            onChanged: (v) => setState(() => _confidence = v),
          ),
          _PrimaryAction(
            label: 'SAVE CHECK-IN',
            onTap: () {
              modules.addMentalCheckIn(
                mood: _mood,
                focus: _focus,
                confidence: _confidence,
              );
              appState.earnCoinsWithFeedback(15, 'Mindset check-in');
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _journalController,
            maxLines: 2,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Match journal',
              hintText: 'What pressure moment did you learn from?',
            ),
          ),
          const SizedBox(height: 10),
          _SecondaryAction(
            label: 'ADD JOURNAL ENTRY',
            onTap: () {
              modules.addJournalEntry(
                'What pressure moment did you learn from?',
                _journalController.text,
              );
              _journalController.clear();
              appState.earnCoinsWithFeedback(20, 'Match journal');
            },
          ),
          const SizedBox(height: 12),
          _ToolkitRow(
            items: const [
              '4-4-4 breathing',
              'Visualize first scoring shot',
              'Reset trigger between balls',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditioningSection(
    LocalModulesViewModel modules,
    AppState appState,
  ) {
    return _ModuleCard(
      title: 'Strength & Conditioning',
      subtitle: modules.recoveryRecommendation,
      icon: Icons.fitness_center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanGrid(
            plans: const {
              'Power': 'Med-ball throws + jump squats',
              'Endurance': '6x60m cricket shuttles',
              'Mobility': 'Hips, thoracic, hamstrings',
              'Movement': 'Lateral crease patterns',
            },
          ),
          const SizedBox(height: 12),
          _ChoiceWrap<ConditioningCategory>(
            values: ConditioningCategory.values,
            selected: _conditioningCategory,
            getLabel: (value) => value.displayName,
            onSelected: (value) =>
                setState(() => _conditioningCategory = value),
          ),
          _SliderRow(
            label: 'Effort',
            value: _effort,
            max: 10,
            onChanged: (v) => setState(() => _effort = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppTheme.neonGreen,
            title: const Text(
              'Discomfort / niggle flagged',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            ),
            value: _niggle,
            onChanged: (value) => setState(() => _niggle = value),
          ),
          _PrimaryAction(
            label: 'LOG S&C SESSION',
            onTap: () {
              modules.addConditioningLog(
                category: _conditioningCategory,
                effort: _effort,
                niggleFlagged: _niggle,
                notes: _niggle ? 'Auto-recovery recommended' : '',
              );
              appState.earnCoinsWithFeedback(25, 'S&C session');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(
    LocalModulesViewModel modules,
    AppState appState,
  ) {
    return _ModuleCard(
      title: 'Nutrition & Hydration',
      subtitle:
          '${modules.hydrationGlasses}/8 glasses • ${modules.mealLogs.length} meals logged',
      icon: Icons.restaurant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (modules.hydrationGlasses / 8).clamp(0, 1),
            backgroundColor: AppTheme.cardSurfaceLight,
            color: AppTheme.neonGreen,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PrimaryAction(
                  label: 'ADD WATER',
                  onTap: () {
                    modules.addHydrationGlass();
                    if (modules.hydrationGlasses == 8) {
                      appState.earnCoinsWithFeedback(15, 'Hydration goal');
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryAction(
                  label: 'RESET',
                  onTap: modules.resetHydration,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mealController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Meal log',
              hintText: 'Banana, yogurt, rice bowl...',
            ),
          ),
          const SizedBox(height: 10),
          _ChoiceWrap<String>(
            values: const ['Training day', 'Match eve', 'Match morning'],
            selected: _mealContext,
            getLabel: (value) => value,
            onSelected: (value) => setState(() => _mealContext = value),
          ),
          const SizedBox(height: 10),
          _PrimaryAction(
            label: 'LOG MEAL',
            onTap: () {
              modules.addMealLog(_mealController.text, _mealContext);
              _mealController.clear();
              appState.earnCoinsWithFeedback(10, 'Meal logged');
            },
          ),
          const SizedBox(height: 12),
          _ToolkitRow(items: modules.groceryList),
        ],
      ),
    );
  }

  Widget _buildGamificationSection(
    LocalModulesViewModel modules,
    AppState appState,
  ) {
    return _ModuleCard(
      title: 'Wallet, Badges & Tiers',
      subtitle:
          '${appState.vCoins} V-Coins • ${modules.tierForCoins(appState.vCoins)} tier',
      icon: Icons.workspace_premium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MetricTile(
                label: 'Multiplier',
                value: 'x${modules.selectedTier.coinMultiplier}',
                color: AppTheme.goldAccent,
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'Redeem',
                value: '\$${(appState.vCoins / 100).toStringAsFixed(0)}',
                color: AppTheme.neonGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (modules.unlockedBadges.isEmpty
                    ? ['First badge waiting']
                    : modules.unlockedBadges)
                .map((badge) => _Badge(label: badge))
                .toList(),
          ),
          const SizedBox(height: 12),
          _SecondaryAction(
            label: 'MOCK PERFECT DAY BONUS',
            onTap: () =>
                appState.earnCoinsWithFeedback(50, 'Perfect day bonus'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(
    LocalModulesViewModel modules,
    AppState appState,
  ) {
    return _ModuleCard(
      title: 'Video Intelligence',
      subtitle: 'Upload queue, tags, statuses, and mock analysis cards.',
      icon: Icons.video_library,
      child: Column(
        children: [
          TextField(
            controller: _videoController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Clip title',
              hintText: 'Cover drive nets',
            ),
          ),
          const SizedBox(height: 10),
          _ChoiceWrap<String>(
            values: const ['Batting', 'Bowling', 'Fielding', 'Match'],
            selected: _videoTag,
            getLabel: (value) => value,
            onSelected: (value) => setState(() => _videoTag = value),
          ),
          const SizedBox(height: 10),
          _PrimaryAction(
            label: 'ADD MOCK VIDEO',
            onTap: () {
              modules.addVideo(_videoController.text, _videoTag);
              _videoController.clear();
            },
          ),
          const SizedBox(height: 12),
          ...modules.videoItems.take(3).toList().asMap().entries.map(
                (entry) => _ListRow(
                  title: entry.value.title,
                  subtitle:
                      '${entry.value.tag} • ${entry.value.status.displayName}',
                  trailing: entry.value.status == VideoStatus.completed
                      ? 'Done'
                      : 'Advance',
                  onTap: () {
                    modules.advanceVideo(entry.key);
                    if (entry.value.status == VideoStatus.analyzing) {
                      appState.earnCoinsWithFeedback(30, 'Video analysis');
                    }
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCoachReviewSection(
    LocalModulesViewModel modules,
    AppState appState,
    bool isYouthMode,
  ) {
    return _ModuleCard(
      title: 'Expert Coach Review',
      subtitle: isYouthMode
          ? 'Youth requests require parent approval before submission.'
          : 'Roster, request flow, and feedback delivery tracking.',
      icon: Icons.sports,
      child: Column(
        children: [
          _ChoiceWrap<String>(
            values: const ['Coach Maya', 'Coach Arjun', 'Coach Priya'],
            selected: _coachName,
            getLabel: (value) => value,
            onSelected: (value) => setState(() => _coachName = value),
          ),
          const SizedBox(height: 10),
          _ChoiceWrap<String>(
            values: const ['Lite', 'Standard', 'Pro Report'],
            selected: _reviewTier,
            getLabel: (value) => value,
            onSelected: (value) => setState(() => _reviewTier = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewNotesController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Coach notes',
              hintText: 'Please review my front-foot balance.',
            ),
          ),
          const SizedBox(height: 10),
          _PrimaryAction(
            label:
                isYouthMode ? 'REQUEST WITH PARENT APPROVAL' : 'SUBMIT REQUEST',
            onTap: () {
              modules.submitCoachReview(
                coachName: _coachName,
                tier: _reviewTier,
                notes: _reviewNotesController.text,
              );
              _reviewNotesController.clear();
              appState.earnCoinsWithFeedback(10, 'Coach request');
            },
          ),
          const SizedBox(height: 12),
          ...modules.coachReviewRequests.take(2).toList().asMap().entries.map(
                (entry) => _ListRow(
                  title: entry.value.coachName,
                  subtitle:
                      '${entry.value.tier} • ${entry.value.delivered ? 'Feedback delivered' : 'Pending review'}',
                  trailing: entry.value.delivered ? 'Open' : 'Deliver',
                  onTap: () => modules.markReviewDelivered(entry.key),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection(
    LocalModulesViewModel modules,
    AppState appState,
    bool isYouthMode,
  ) {
    return _ModuleCard(
      title: 'Social & Community',
      subtitle: 'Achievement wall, reactions, reporting, and no-DM policy.',
      icon: Icons.groups,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isYouthMode)
            const _SafetyNote(
              text:
                  'Youth Mode: club wall is read-first and private messaging is not available.',
            ),
          TextField(
            controller: _communityController,
            maxLength: 280,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Achievement post',
              hintText: 'Logged a new drill streak...',
            ),
          ),
          _PrimaryAction(
            label: 'POST ACHIEVEMENT',
            onTap: () {
              modules.addCommunityPost(_communityController.text);
              _communityController.clear();
              appState.earnCoinsWithFeedback(10, 'Community post');
            },
          ),
          const SizedBox(height: 12),
          ...modules.communityPosts.take(3).toList().asMap().entries.map(
                (entry) => _ListRow(
                  title: entry.value.author,
                  subtitle:
                      '${entry.value.body} • ${entry.value.reactions} reactions${entry.value.reported ? ' • reported' : ''}',
                  trailing: entry.value.reported ? 'Hidden' : 'React',
                  onTap: () => modules.reactToPost(entry.key),
                  onLongPress: () => modules.reportPost(entry.key),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSharingSection(
    LocalModulesViewModel modules,
    AppState appState,
    bool isYouthMode,
  ) {
    return _ModuleCard(
      title: 'Sharing & Instagram',
      subtitle: 'Share-card drafts with Youth Mode guardrails.',
      icon: Icons.ios_share,
      child: Column(
        children: [
          if (isYouthMode)
            const _SafetyNote(
              text:
                  'Youth Mode: parent consent should be checked before external sharing.',
            ),
          _ChoiceWrap<String>(
            values: const ['Square 1:1', 'Story 9:16', 'Horizontal 16:9'],
            selected: _shareFormat,
            getLabel: (value) => value,
            onSelected: (value) => setState(() => _shareFormat = value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _captionController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Caption',
              hintText: '@VllowSports #Dugout',
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppTheme.neonGreen,
            title: const Text(
              'Include stats',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            ),
            value: _includeStats,
            onChanged: (value) => setState(() => _includeStats = value),
          ),
          _PrimaryAction(
            label: 'GENERATE SHARE CARD',
            onTap: () {
              modules.createShareCard(
                format: _shareFormat,
                caption: _captionController.text,
                includeStats: _includeStats,
              );
              appState.earnCoinsWithFeedback(10, 'Share card');
            },
          ),
          const SizedBox(height: 12),
          ...modules.shareDrafts.take(2).map(
                (draft) => _ListRow(
                  title: draft.format,
                  subtitle:
                      '${draft.caption} • ${draft.includeStats ? 'stats on' : 'stats off'}',
                  trailing: 'Draft',
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEntitlementSection(LocalModulesViewModel modules) {
    return _ModuleCard(
      title: 'Monetization & Entitlements',
      subtitle:
          '${modules.trialDaysRemaining} trial days left. Local feature gates only.',
      icon: Icons.lock_open,
      child: Column(
        children: [
          ...SubscriptionTier.values.map(
            (tier) => _ListRow(
              title: tier.displayName,
              subtitle:
                  'Coin multiplier x${tier.coinMultiplier} • ${_tierLimits(tier)}',
              trailing: modules.selectedTier == tier ? 'Active' : 'Select',
              onTap: () => modules.selectTier(tier),
            ),
          ),
        ],
      ),
    );
  }

  String _tierLimits(SubscriptionTier tier) {
    return switch (tier) {
      SubscriptionTier.rookie => 'starter drills, limited scans',
      SubscriptionTier.dugout => 'full drills, more coach chat',
      SubscriptionTier.pavilion => 'pro reports, priority reviews',
      SubscriptionTier.nextGen => 'youth-safe pro controls',
    };
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.neonGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.max = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            '$label $value',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: max.toDouble(),
            divisions: max - 1,
            activeColor: AppTheme.neonGreen,
            inactiveColor: AppTheme.cardSurfaceLight,
            onChanged: (next) => onChanged(next.round()),
          ),
        ),
      ],
    );
  }
}

class _ChoiceWrap<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T value) getLabel;
  final ValueChanged<T> onSelected;

  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.getLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = value == selected;
        return ChoiceChip(
          label: Text(getLabel(value)),
          selected: isSelected,
          selectedColor: AppTheme.neonGreen,
          backgroundColor: AppTheme.cardSurfaceLight,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (_) => onSelected(value),
        );
      }).toList(),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.neonGreen,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ToolkitRow extends StatelessWidget {
  final List<String> items;

  const _ToolkitRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlanGrid extends StatelessWidget {
  final Map<String, String> plans;

  const _PlanGrid({required this.plans});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: plans.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.goldAccent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ListRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              trailing,
              style: const TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  final String text;

  const _SafetyNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.goldAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}
