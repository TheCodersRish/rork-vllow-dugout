import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vllow_dugout/models/player_profile.dart';
import 'package:vllow_dugout/providers/player_profile_view_model.dart';

void main() {
  test('persists player profile and derives youth mode fields', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final viewModel = PlayerProfileViewModel(prefs);
    final youthDob = DateTime(DateTime.now().year - 12);

    viewModel.updateProfile(
      PlayerProfile(
        dateOfBirth: youthDob,
        position: PlayerPosition.wicketkeeper,
        experienceLevel: ExperienceLevel.academy,
        goals: 'Improve keeping footwork',
        weeklyAvailability: const ['Tue', 'Thu'],
        parentEmail: 'parent@example.com',
        parentConsentGranted: true,
      ),
    );

    final restored = PlayerProfileViewModel(prefs);

    expect(restored.profile.position, PlayerPosition.wicketkeeper);
    expect(restored.profile.experienceLevel, ExperienceLevel.academy);
    expect(restored.profile.goals, 'Improve keeping footwork');
    expect(restored.profile.weeklyAvailability, ['Tue', 'Thu']);
    expect(restored.profile.parentEmail, 'parent@example.com');
    expect(restored.profile.parentConsentGranted, isTrue);
    expect(restored.profile.isYouthMode, isTrue);
    expect(restored.profile.ageGroup, 'U13');
  });
}
