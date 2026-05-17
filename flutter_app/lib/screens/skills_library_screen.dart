import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drill.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import 'drill_session_screen.dart';

class SkillsLibraryScreen extends StatefulWidget {
  const SkillsLibraryScreen({super.key});

  @override
  State<SkillsLibraryScreen> createState() => _SkillsLibraryScreenState();
}

class _SkillsLibraryScreenState extends State<SkillsLibraryScreen> {
  final _searchController = TextEditingController();
  DrillCategory? _selectedCategory;
  Difficulty? _selectedDifficulty;
  bool _savedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDrill(Drill drill) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DrillSessionScreen(drill: drill),
      ),
    );
  }

  List<Drill> _filteredDrills(AppState appState) {
    final query = _searchController.text.trim().toLowerCase();
    return appState.gameData.drills.where((drill) {
      final matchesQuery = query.isEmpty ||
          drill.title.toLowerCase().contains(query) ||
          drill.subtitle.toLowerCase().contains(query) ||
          drill.category.displayName.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null || drill.category == _selectedCategory;
      final matchesDifficulty = _selectedDifficulty == null ||
          drill.difficulty == _selectedDifficulty;
      final matchesSaved = !_savedOnly || appState.isBookmarked(drill.id);
      return matchesQuery &&
          matchesCategory &&
          matchesDifficulty &&
          matchesSaved;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            final drills = _filteredDrills(appState);
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildSearchField(),
                      const SizedBox(height: 14),
                      _buildFilters(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'DRILL LIBRARY',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${drills.length} results',
                            style: const TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (drills.isEmpty)
                        _buildEmptyState()
                      else
                        ...drills.map(
                          (drill) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DrillLibraryCard(
                              drill: drill,
                              completed:
                                  appState.gameData.isDrillCompleted(drill.id),
                              bookmarked: appState.isBookmarked(drill.id),
                              onOpen: () => _openDrill(drill),
                              onBookmark: () =>
                                  appState.toggleBookmark(drill.id),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            );
          },
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
                'Skills Library',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Search drills by skill, level, and role.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search batting, bowling, fielding...',
        prefixIcon:
            const Icon(Icons.search, color: AppTheme.textTertiary, size: 20),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textTertiary),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterRow<DrillCategory>(
          label: 'Category',
          values: DrillCategory.values,
          selectedValue: _selectedCategory,
          getLabel: (category) => category.displayName,
          onSelected: (category) {
            setState(() {
              _selectedCategory =
                  _selectedCategory == category ? null : category;
            });
          },
        ),
        const SizedBox(height: 10),
        _FilterRow<Difficulty>(
          label: 'Difficulty',
          values: Difficulty.values,
          selectedValue: _selectedDifficulty,
          getLabel: (difficulty) => difficulty.displayName,
          onSelected: (difficulty) {
            setState(() {
              _selectedDifficulty =
                  _selectedDifficulty == difficulty ? null : difficulty;
            });
          },
        ),
        const SizedBox(height: 10),
        FilterChip(
          label: const Text('Saved drills only'),
          selected: _savedOnly,
          selectedColor: AppTheme.neonGreen,
          backgroundColor: AppTheme.cardSurface,
          labelStyle: TextStyle(
            color: _savedOnly ? Colors.black : AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (selected) => setState(() => _savedOnly = selected),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: AppTheme.textTertiary, size: 32),
          SizedBox(height: 10),
          Text(
            'No drills match those filters yet.',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different category, difficulty, or search term.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FilterRow<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final T? selectedValue;
  final String Function(T value) getLabel;
  final ValueChanged<T> onSelected;

  const _FilterRow({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.getLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: values.map((value) {
              final selected = selectedValue == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(getLabel(value)),
                  selected: selected,
                  selectedColor: AppTheme.neonGreen,
                  backgroundColor: AppTheme.cardSurface,
                  labelStyle: TextStyle(
                    color: selected ? Colors.black : AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => onSelected(value),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DrillLibraryCard extends StatelessWidget {
  final Drill drill;
  final bool completed;
  final bool bookmarked;
  final VoidCallback onOpen;
  final VoidCallback onBookmark;

  const _DrillLibraryCard({
    required this.drill,
    required this.completed,
    required this.bookmarked,
    required this.onOpen,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: completed
                ? AppTheme.neonGreen.withValues(alpha: 0.35)
                : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: completed
                    ? AppTheme.neonGreen.withValues(alpha: 0.12)
                    : AppTheme.cardSurfaceLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                completed ? Icons.check_circle : Icons.play_arrow_rounded,
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
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drill.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MiniBadge(drill.category.displayName),
                      _MiniBadge(drill.difficulty.displayName),
                      _MiniBadge(drill.durationFormatted),
                      _MiniBadge('+${drill.coinReward} V-Coins'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: bookmarked ? AppTheme.neonGreen : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;

  const _MiniBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
