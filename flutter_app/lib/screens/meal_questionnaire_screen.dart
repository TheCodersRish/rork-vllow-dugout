import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../models/meal_profile.dart';
import '../utils/app_theme.dart';

class MealQuestionnaireScreen extends StatefulWidget {
  final MealProfile profile;
  final ValueChanged<MealProfile> onSave;

  const MealQuestionnaireScreen({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<MealQuestionnaireScreen> createState() =>
      _MealQuestionnaireScreenState();
}

class _MealQuestionnaireScreenState extends State<MealQuestionnaireScreen> {
  late MealProfile _profile;
  final _allergiesController = TextEditingController();
  final _dislikesController = TextEditingController();
  final _calorieController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profile = MealProfile(
      age: widget.profile.age,
      sex: widget.profile.sex,
      heightCm: widget.profile.heightCm,
      weightKg: widget.profile.weightKg,
      activityLevel: widget.profile.activityLevel,
      trainingHoursPerWeek: widget.profile.trainingHoursPerWeek,
      dietPreference: widget.profile.dietPreference,
      cuisinePreference: widget.profile.cuisinePreference,
      allergies: List.from(widget.profile.allergies),
      dislikes: List.from(widget.profile.dislikes),
      calorieTarget: widget.profile.calorieTarget,
      notes: widget.profile.notes,
    );
    _allergiesController.text = _profile.allergies.join(', ');
    _dislikesController.text = _profile.dislikes.join(', ');
    if (_profile.calorieTarget != null) {
      _calorieController.text = '${_profile.calorieTarget}';
    }
    _notesController.text = _profile.notes;
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _dislikesController.dispose();
    _calorieController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    _profile.allergies = _allergiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    _profile.dislikes = _dislikesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final cal = int.tryParse(_calorieController.text);
    _profile.calorieTarget = cal;
    _profile.notes = _notesController.text;

    widget.onSave(_profile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildNavBar(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Tell us about you',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'We\'ll personalise your meal plan based on your body, diet, and preferences.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    _buildSectionHeader('ABOUT YOU'),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      children: [
                        _buildStepperRow(
                          'Age', '${_profile.age}', 'yrs',
                          _profile.age > 14, _profile.age < 60,
                          () => setState(() => _profile.age--),
                          () => setState(() => _profile.age++),
                        ),
                        const Divider(color: AppTheme.border, height: 1),
                        _buildSexPicker(),
                        const Divider(color: AppTheme.border, height: 1),
                        _buildStepperRow(
                          'Height', '${_profile.heightCm}', 'cm',
                          _profile.heightCm > 120, _profile.heightCm < 220,
                          () => setState(() => _profile.heightCm--),
                          () => setState(() => _profile.heightCm++),
                        ),
                        const Divider(color: AppTheme.border, height: 1),
                        _buildStepperRow(
                          'Weight', '${_profile.weightKg}', 'kg',
                          _profile.weightKg > 30, _profile.weightKg < 150,
                          () => setState(() => _profile.weightKg--),
                          () => setState(() => _profile.weightKg++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('DIET PREFERENCE'),
                    const SizedBox(height: 12),
                    _buildDietPicker(),
                    const SizedBox(height: 24),

                    _buildSectionHeader('CUISINE PREFERENCE'),
                    const SizedBox(height: 12),
                    _buildCuisinePicker(),
                    const SizedBox(height: 24),

                    _buildSectionHeader('TRAINING'),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      children: [
                        _buildActivityLevelPicker(),
                        const Divider(color: AppTheme.border, height: 1),
                        _buildStepperRow(
                          'Hours / Week',
                          '${_profile.trainingHoursPerWeek}', 'hrs',
                          _profile.trainingHoursPerWeek > 0,
                          _profile.trainingHoursPerWeek < 40,
                          () => setState(() => _profile.trainingHoursPerWeek--),
                          () => setState(() => _profile.trainingHoursPerWeek++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('DIETARY RESTRICTIONS'),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      children: [
                        _buildInlineTextField(
                          controller: _allergiesController,
                          label: 'Allergies',
                          hint: 'e.g. nuts, shellfish, dairy',
                        ),
                        const Divider(color: AppTheme.border, height: 1),
                        _buildInlineTextField(
                          controller: _dislikesController,
                          label: 'Dislikes',
                          hint: 'e.g. broccoli, liver',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('OPTIONAL'),
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      children: [
                        _buildInlineTextField(
                          controller: _calorieController,
                          label: 'Calorie Target',
                          hint: 'e.g. 2500',
                          keyboardType: TextInputType.number,
                        ),
                        const Divider(color: AppTheme.border, height: 1),
                        _buildInlineTextField(
                          controller: _notesController,
                          label: 'Notes',
                          hint: 'Any other preferences...',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen,
                          borderRadius: BorderRadius.circular(29),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonGreen.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SAVE & GENERATE PLAN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Meal Profile',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.neonGreen,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDietPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DietPreference.values.map((diet) {
        final isSelected = diet == _profile.dietPreference;
        return GestureDetector(
          onTap: () => setState(() => _profile.dietPreference = diet),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.neonGreen : AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(29),
              border: Border.all(
                color: isSelected ? AppTheme.neonGreen : AppTheme.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  diet.icon,
                  color: isSelected ? Colors.black : AppTheme.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  diet.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCuisinePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CuisinePreference.values.map((cuisine) {
        final isSelected = cuisine == _profile.cuisinePreference;
        return GestureDetector(
          onTap: () => setState(() => _profile.cuisinePreference = cuisine),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.neonGreen : AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(29),
              border: Border.all(
                color: isSelected ? AppTheme.neonGreen : AppTheme.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Text(
              cuisine.displayName,
              style: TextStyle(
                color: isSelected ? Colors.black : AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepperRow(String label, String value, String suffix,
      bool canDecrease, bool canIncrease, VoidCallback onDecrease,
      VoidCallback onIncrease) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
          ),
          GestureDetector(
            onTap: canDecrease ? onDecrease : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.cardSurfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove,
                  color: canDecrease
                      ? AppTheme.textPrimary
                      : AppTheme.textTertiary,
                  size: 18),
            ),
          ),
          SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(width: 2),
                Text(suffix,
                    style: const TextStyle(
                        color: AppTheme.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: canIncrease ? onIncrease : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.cardSurfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add,
                  color: canIncrease
                      ? AppTheme.textPrimary
                      : AppTheme.textTertiary,
                  size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Text('Sex',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardSurfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: Sex.values.map((sex) {
                final isSelected = sex == _profile.sex;
                return GestureDetector(
                  onTap: () => setState(() => _profile.sex = sex),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.neonGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      sex.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Level',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ActivityLevel.values.map((level) {
                final isSelected = level == _profile.activityLevel;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _profile.activityLevel = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.neonGreen
                            : AppTheme.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: Text(
                        level.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
            child: SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                hintStyle: const TextStyle(
                    color: AppTheme.textTertiary, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
