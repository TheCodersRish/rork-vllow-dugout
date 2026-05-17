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
    modules.addJournalEntry('Prompt', 'Pressure against spin made me nervous.');
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
    modules.advanceVideo(0);
    modules.advanceVideo(0);
    modules.submitCoachReview(
      coachName: 'Coach Maya',
      tier: 'Standard',
      notes: 'Front foot balance',
    );
    modules.markReviewDelivered(0);
    modules.addCommunityPost('Finished my mobility block.');
    modules.reactToPost(0);
    modules.commentOnPost(0);
    modules.reportPost(0);
    modules.blockPostAuthor(0);
    modules.createShareCard(
      format: 'Story 9:16',
      caption: 'Training complete',
      includeStats: true,
    );
    modules.saveShareCard(0);
    modules.markShareCardShared(0);
    modules.selectTier(SubscriptionTier.dugout);
    expect(modules.registerReward(450), 450);
    expect(modules.registerReward(100), 50);
    expect(modules.registerReward(1), 0);

    final restored = LocalModulesViewModel(prefs);

    expect(restored.mentalCheckIns, hasLength(1));
    expect(restored.journalThemes, contains('Pressure response'));
    expect(restored.journalThemes, contains('Spin confidence'));
    expect(restored.conditioningLogs.first.category,
        ConditioningCategory.mobility);
    expect(restored.recoveryRecommendation, contains('Niggle'));
    expect(restored.hydrationGlasses, 1);
    expect(restored.mealLogs.first.title, 'Rice bowl');
    expect(restored.videoItems.first.status, VideoStatus.completed);
    expect(restored.videoItems.first.drillPrescription, isNotEmpty);
    expect(restored.coachReviewRequests.first.coachName, 'Coach Maya');
    expect(restored.coachReviewRequests.first.delivered, isTrue);
    expect(restored.coachReviewRequests.first.feedback, isNotEmpty);
    expect(restored.communityPosts.first.comments, 1);
    expect(restored.communityPosts.first.reported, isTrue);
    expect(restored.communityPosts.first.blocked, isTrue);
    expect(restored.shareDrafts.first.format, 'Story 9:16');
    expect(restored.shareDrafts.first.saved, isTrue);
    expect(restored.shareDrafts.first.shared, isTrue);
    expect(restored.selectedTier, SubscriptionTier.dugout);
    expect(restored.dailyRewardTotal, 500);
    expect(restored.dailyRewardRemaining, 0);
    expect(restored.recipeCards, isNotEmpty);
    expect(restored.addOns, isNotEmpty);
    expect(restored.entitlementLimits(SubscriptionTier.dugout), isNotEmpty);
  });
}
