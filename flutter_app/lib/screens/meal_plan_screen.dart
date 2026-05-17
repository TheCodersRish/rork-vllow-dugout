import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal_plan.dart';
import '../models/meal_profile.dart';
import '../providers/meal_plan_view_model.dart';
import '../utils/app_theme.dart';
import 'meal_questionnaire_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  MealGoal _selectedGoal = MealGoal.training;
  DietPreference _selectedDiet = DietPreference.omnivore;
  bool _checkedInitial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedInitial) {
      _checkedInitial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<MealPlanViewModel>();
        if (vm.shouldShowQuestionnaire) {
          _openQuestionnaire(vm, autoGenerate: true);
        }
      });
    }
  }

  void _openQuestionnaire(MealPlanViewModel vm, {bool autoGenerate = false}) {
    vm.markQuestionnaireShown();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MealQuestionnaireScreen(
        profile: vm.mealProfile ?? MealProfile(),
        onSave: (profile) {
          vm.saveMealProfile(profile);
          setState(() {
            _selectedDiet = profile.dietPreference;
          });
          if (autoGenerate) {
            vm.generatePlan(_selectedGoal, profile.dietPreference);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanViewModel>(
      builder: (context, vm, _) {
        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildProfileCard(vm)),
            SliverToBoxAdapter(child: _buildGoalSelector()),
            SliverToBoxAdapter(child: _buildDietSelector()),
            SliverToBoxAdapter(child: _buildGenerateButton(vm)),
            if (vm.isLoading) SliverToBoxAdapter(child: _buildLoadingState()),
            if (vm.currentPlan != null && !vm.isLoading) ...[
              SliverToBoxAdapter(child: _buildMacroSummary(vm.currentPlan!)),
              SliverToBoxAdapter(child: _buildMealsSection(vm.currentPlan!)),
            ],
            if (vm.savedPlans.length > 1)
              SliverToBoxAdapter(child: _buildSavedPlans(vm)),
            if (vm.currentPlan == null && !vm.isLoading && vm.savedPlans.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState()),
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard(MealPlanViewModel vm) {
    final hasProfile = vm.hasProfile;
    return GestureDetector(
      onTap: () => _openQuestionnaire(vm),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasProfile ? AppTheme.border : AppTheme.neonGreen.withOpacity(0.3),
            width: hasProfile ? 0.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppTheme.neonGreen, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasProfile ? 'YOUR PROFILE' : 'START HERE',
                    style: const TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasProfile
                        ? '${vm.mealProfile!.age}yr \u2022 ${vm.mealProfile!.sex.displayName} \u2022 ${vm.mealProfile!.heightCm}cm \u2022 ${vm.mealProfile!.weightKg}kg'
                        : 'Set up your profile for AI-personalised plans',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              hasProfile ? Icons.chevron_right : Icons.arrow_forward,
              color: hasProfile ? AppTheme.textTertiary : AppTheme.neonGreen,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'GOAL',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MealGoal.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final goal = MealGoal.values[index];
              final isSelected = goal == _selectedGoal;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.neonGreen : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.neonGreen
                          : AppTheme.border,
                      width: 0.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.neonGreen.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        goal.icon,
                        color:
                            isSelected ? Colors.black : AppTheme.textTertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        goal.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDietSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'DIET',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: DietPreference.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final diet = DietPreference.values[index];
              final isSelected = diet == _selectedDiet;
              return GestureDetector(
                onTap: () => setState(() => _selectedDiet = diet),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.neonGreen : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.neonGreen
                          : AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diet.icon,
                        color:
                            isSelected ? Colors.black : AppTheme.textTertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        diet.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(MealPlanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: GestureDetector(
        onTap: vm.isLoading
            ? null
            : () => vm.generatePlan(_selectedGoal, _selectedDiet),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: vm.isLoading
                ? null
                : LinearGradient(
                    colors: [
                      AppTheme.neonGreen,
                      AppTheme.neonGreen.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: vm.isLoading ? AppTheme.cardSurface : null,
            borderRadius: BorderRadius.circular(29),
            boxShadow: vm.isLoading
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: vm.isLoading ? AppTheme.textTertiary : Colors.black,
                size: 20,
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(
                    'Generate Meal Plan',
                    style: TextStyle(
                      color:
                          vm.isLoading ? AppTheme.textTertiary : Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vm.hasProfile
                        ? 'Personalised to your profile'
                        : 'AI-powered nutrition for cricketers',
                    style: TextStyle(
                      color: vm.isLoading
                          ? AppTheme.textTertiary.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.neonGreen, size: 16),
              SizedBox(width: 8),
              Text(
                'AI crafting your plan...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Calculating macros from your profile',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSummary(MealPlan plan) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            '${plan.totalCalories}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const Text(
            'CALORIES',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(plan.goal.icon, color: AppTheme.neonGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                plan.goal.displayName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppTheme.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d, yyyy').format(plan.date),
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _macroChip('P: ${plan.totalProtein}g', Colors.blueAccent),
              const SizedBox(width: 8),
              _macroChip('C: ${plan.totalCarbs}g', AppTheme.goldAccent),
              const SizedBox(width: 8),
              _macroChip('F: ${plan.totalFat}g', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildMealsSection(MealPlan plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'MEALS',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          ...plan.meals.map((meal) => _MealCard(meal: meal)),
        ],
      ),
    );
  }

  Widget _buildSavedPlans(MealPlanViewModel vm) {
    final plans = vm.savedPlans.skip(1).take(5).toList();
    if (plans.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREVIOUS PLANS',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          ...plans.map((plan) {
            return GestureDetector(
              onTap: () => vm.loadPlan(plan),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(plan.goal.icon, color: AppTheme.neonGreen, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${plan.goal.displayName} \u2022 ${plan.diet.displayName}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${plan.totalCalories} kcal \u2022 ${DateFormat('MMM d').format(plan.date)}',
                            style: const TextStyle(
                                color: AppTheme.textTertiary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppTheme.textTertiary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu,
                color: AppTheme.neonGreen, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'No meal plans yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set up your profile and generate your first plan',
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatefulWidget {
  final Meal meal;
  const _MealCard({required this.meal});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: meal.type.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(meal.type.icon, color: meal.type.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${meal.type.displayName} \u2022 ${meal.prepTime}',
                          style: const TextStyle(
                              color: AppTheme.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${meal.calories}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'kcal',
                    style:
                        TextStyle(color: AppTheme.textTertiary, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more,
                        color: AppTheme.textTertiary, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(meal),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 12),
          if (meal.description.isNotEmpty) ...[
            Text(
              meal.description,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              _macroBar('Protein', meal.protein, Colors.blueAccent),
              const SizedBox(width: 8),
              _macroBar('Carbs', meal.carbs, AppTheme.goldAccent),
              const SizedBox(width: 8),
              _macroBar('Fat', meal.fat, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'INGREDIENTS',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: meal.ingredients.map((ing) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ing,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _macroBar(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '${value}g',
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
