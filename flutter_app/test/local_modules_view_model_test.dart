import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vllow_dugout/models/local_modules.dart';
import 'package:vllow_dugout/providers/local_modules_view_model.dart';

void main() {
  test('persists local module foundations', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final modules = LocalModulesViewModel(prefs);

    modules.addMentalCheckIn(mood: 8, focus: 7, confidence: 9);
    modules.addJournalEntry('Prompt', 'Handled pressure better today.');
    modules.addConditioningLog(
      category: ConditioningCategory.mobility,
      effort: 6,
      niggleFlagged: true,
      notes: 'Tight hamstring',
    );
    modules.addHydrationGlass();
    modules.addMealLog('Rice bowl', 'Match eve');
    modules.addVideo('Cover drive nets', 'Batting');
    modules.advanceVideo(0);
    modules.submitCoachReview(
      coachName: 'Coach Maya',
      tier: 'Standard',
      notes: 'Front foot balance',
    );
    modules.addCommunityPost('Finished my mobility block.');
    modules.createShareCard(
      format: 'Story 9:16',
      caption: 'Training complete',
      includeStats: true,
    );
    modules.selectTier(SubscriptionTier.dugout);

    final restored = LocalModulesViewModel(prefs);

    expect(restored.mentalCheckIns, hasLength(1));
    expect(restored.journalEntries.first.response,
        'Handled pressure better today.');
    expect(restored.conditioningLogs.first.category,
        ConditioningCategory.mobility);
    expect(restored.hydrationGlasses, 1);
    expect(restored.mealLogs.first.title, 'Rice bowl');
    expect(restored.videoItems.first.status, VideoStatus.uploading);
    expect(restored.coachReviewRequests.first.coachName, 'Coach Maya');
    expect(restored.communityPosts.first.body, 'Finished my mobility block.');
    expect(restored.shareDrafts.first.format, 'Story 9:16');
    expect(restored.selectedTier, SubscriptionTier.dugout);
  });
}
