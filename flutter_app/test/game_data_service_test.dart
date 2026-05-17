import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vllow_dugout/models/performance_stats.dart';
import 'package:vllow_dugout/services/game_data_service.dart';
import 'package:vllow_dugout/utils/mock_data.dart';

void main() {
  test('persists completed drills, bookmarks, matches, and coin history',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final drill = MockData.drills.first;
    final service = GameDataService(prefs: prefs);

    expect(service.completeDrill(drill.id), isTrue);
    expect(service.completeDrill(drill.id), isFalse);
    service.toggleBookmark(drill.id);
    service.earnCoins(25, reason: 'Test reward');
    service.addMatch(
      PerformanceStats(
        runsScored: 64,
        ballsFaced: 42,
        strikeRateChange: 8.5,
        opponent: 'Academy XI',
        coinBonus: 35,
      ),
    );

    final restored = GameDataService(prefs: prefs);

    expect(restored.isDrillCompleted(drill.id), isTrue);
    expect(restored.isBookmarked(drill.id), isTrue);
    expect(restored.drillsCompleted, service.drillsCompleted);
    expect(restored.vCoins, service.vCoins);
    expect(restored.recentCoinTransactions.first.reason, 'Test reward');
    expect(restored.matchHistory.first.opponent, 'Academy XI');
  });
}
