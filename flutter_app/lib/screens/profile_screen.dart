import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_profile.dart';
import '../providers/app_state.dart';
import '../providers/auth_view_model.dart';
import '../providers/player_profile_view_model.dart';
import '../services/health_service.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, AppState>(
      builder: (context, auth, appState, _) {
        final userName = auth.currentUser?.name ?? 'Champion';
        final userEmail = auth.currentUser?.email ?? 'champion@vllow.app';
        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'V';

        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAvatarSection(initial, userName, userEmail),
                  const SizedBox(height: 20),
                  _buildCoinsBadge(appState),
                  const SizedBox(height: 24),
                  _buildStatsGrid(appState),
                  const SizedBox(height: 24),
                  const _PlayerProfileSection(),
                  const SizedBox(height: 24),
                  _HealthSection(),
                  const SizedBox(height: 16),
                  _buildIntegrationsCard(),
                  const SizedBox(height: 24),
                  _buildSignOutButton(context, auth),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarSection(String initial, String name, String email) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardSurfaceLight,
            border: Border.all(color: AppTheme.neonGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonGreen.withOpacity(0.2),
                blurRadius: 12,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCoinsBadge(AppState appState) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.goldAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(29),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppTheme.goldAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              '${appState.vCoins} V-COINS',
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
    );
  }

  Widget _buildStatsGrid(AppState appState) {
    final stats = [
      _StatItem('DRILLS DONE', '${appState.drillsCompleted}',
          Icons.fitness_center, AppTheme.neonGreen),
      _StatItem('WIN STREAK', '${appState.winStreak}',
          Icons.local_fire_department, Colors.orange),
      _StatItem('GLOBAL RANK', '#${appState.globalRank}', Icons.leaderboard,
          Colors.blueAccent),
      _StatItem(
          'TRAINING',
          '${(appState.drillsCompleted * 15 / 60).toStringAsFixed(0)}h',
          Icons.timer,
          Colors.purpleAccent),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((stat) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(stat.icon, color: stat.color, size: 16),
              ),
              const SizedBox(height: 8),
              Text(
                stat.label,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntegrationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_cricket,
                color: Colors.blueAccent, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cric Clubs',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sync your club stats & fixtures',
                  style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SOON',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthViewModel auth) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        auth.signOut();
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 18),
            SizedBox(width: 8),
            Text(
              'SIGN OUT',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSection extends StatefulWidget {
  @override
  State<_HealthSection> createState() => _HealthSectionState();
}

class _PlayerProfileSection extends StatefulWidget {
  const _PlayerProfileSection();

  @override
  State<_PlayerProfileSection> createState() => _PlayerProfileSectionState();
}

class _PlayerProfileSectionState extends State<_PlayerProfileSection> {
  late final TextEditingController _goalsController;
  late final TextEditingController _parentEmailController;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final profile = context.read<PlayerProfileViewModel>().profile;
    _goalsController = TextEditingController(text: profile.goals);
    _parentEmailController =
        TextEditingController(text: profile.parentEmail ?? '');
  }

  @override
  void dispose() {
    _goalsController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(
    PlayerProfileViewModel viewModel,
    PlayerProfile profile,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: profile.dateOfBirth ?? DateTime(now.year - 16),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
    );
    if (picked != null) {
      viewModel.updateDateOfBirth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProfileViewModel>(
      builder: (context, viewModel, _) {
        final profile = viewModel.profile;
        final isYouthMode = profile.isYouthMode;
        final dobLabel = profile.dateOfBirth == null
            ? 'Add date of birth'
            : '${profile.dateOfBirth!.month}/${profile.dateOfBirth!.day}/${profile.dateOfBirth!.year}';

        if (_goalsController.text != profile.goals) {
          _goalsController.text = profile.goals;
        }
        if (_parentEmailController.text != (profile.parentEmail ?? '')) {
          _parentEmailController.text = profile.parentEmail ?? '';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PLAYER PROFILE',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
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
                      Expanded(
                        child: _ProfileMetric(
                          label: 'AGE GROUP',
                          value: profile.ageGroup,
                          icon: Icons.cake,
                          color: isYouthMode
                              ? AppTheme.goldAccent
                              : AppTheme.neonGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileMetric(
                          label: 'POSITION',
                          value: profile.position.displayName,
                          icon: Icons.sports_cricket,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  if (isYouthMode) ...[
                    const SizedBox(height: 14),
                    _buildYouthBanner(profile, viewModel),
                  ],
                  const SizedBox(height: 16),
                  _buildDateButton(dobLabel, () {
                    _pickDateOfBirth(viewModel, profile);
                  }),
                  const SizedBox(height: 12),
                  _buildDropdown<PlayerPosition>(
                    label: 'Primary role',
                    value: profile.position,
                    values: PlayerPosition.values,
                    getLabel: (value) => value.displayName,
                    onChanged: (value) => viewModel.updatePosition(value),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<ExperienceLevel>(
                    label: 'Experience',
                    value: profile.experienceLevel,
                    values: ExperienceLevel.values,
                    getLabel: (value) => value.displayName,
                    onChanged: (value) =>
                        viewModel.updateExperienceLevel(value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalsController,
                    minLines: 2,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    onSubmitted: viewModel.updateGoals,
                    onEditingComplete: () {
                      viewModel.updateGoals(_goalsController.text);
                      FocusScope.of(context).unfocus();
                    },
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Training goals',
                      hintText: 'What should Vllow help you improve?',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'WEEKLY AVAILABILITY',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _days.map((day) {
                      final selected = profile.weeklyAvailability.contains(day);
                      return ChoiceChip(
                        label: Text(day),
                        selected: selected,
                        selectedColor: AppTheme.neonGreen,
                        backgroundColor: AppTheme.cardSurfaceLight,
                        labelStyle: TextStyle(
                          color: selected ? Colors.black : AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => viewModel.toggleAvailability(day),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month,
                color: AppTheme.neonGreen, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: AppTheme.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) getLabel,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppTheme.cardSurfaceLight,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(getLabel(item)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  Widget _buildYouthBanner(
    PlayerProfile profile,
    PlayerProfileViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.goldAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: AppTheme.goldAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'YOUTH MODE ACTIVE',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Content, leaderboards, and sharing can now use age-group guardrails.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _parentEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Parent / guardian email',
              hintText: 'parent@example.com',
            ),
            onSubmitted: (value) => viewModel.updateParentConsent(
              parentEmail: value,
              granted: profile.parentConsentGranted,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.neonGreen,
            title: const Text(
              'Parent consent received',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            value: profile.parentConsentGranted,
            onChanged: (value) => viewModel.updateParentConsent(
              parentEmail: _parentEmailController.text,
              granted: value,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthSectionState extends State<_HealthSection> {
  late HealthService _healthService;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _healthService = HealthService();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'HEALTH',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        if (!_healthService.isAuthorized) _buildConnectCard(),
        if (_healthService.isAuthorized && _healthService.todaySummary != null)
          _buildHealthData(),
      ],
    );
  }

  Widget _buildConnectCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite,
                    color: Colors.redAccent, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HEALTH DATA',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connect Apple Health or Google Fit',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await _healthService.requestAuthorization();
                    setState(() => _initialized = true);
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Apple Health',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await _healthService.requestAuthorization();
                    setState(() => _initialized = true);
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center,
                            color: Colors.blueAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Google Fit',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthData() {
    final data = _healthService.todaySummary!;
    return Column(
      children: [
        Container(
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TODAY\'S HEALTH',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _healthMetric(Icons.directions_walk, '${data.steps}', 'Steps',
                      AppTheme.neonGreen),
                  _healthMetric(Icons.local_fire_department,
                      '${data.activeCalories}', 'Active Cal', Colors.orange),
                  _healthMetric(Icons.favorite, '${data.restingHeartRate}',
                      'Resting HR', Colors.redAccent),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _healthMetric(
                      Icons.straighten,
                      '${data.distanceKm.toStringAsFixed(1)}km',
                      'Distance',
                      Colors.blueAccent),
                  _healthMetric(Icons.timer, '${data.exerciseMinutes}min',
                      'Exercise', Colors.purpleAccent),
                  _healthMetric(
                      Icons.bedtime,
                      '${data.sleepHours.toStringAsFixed(1)}h',
                      'Sleep',
                      Colors.indigoAccent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.air, color: AppTheme.neonGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VO2 MAX',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.vo2Max} ml/kg/min',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ABOVE AVG',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _healthMetric(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
