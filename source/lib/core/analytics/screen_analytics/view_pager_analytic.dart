import 'package:flutter/foundation.dart';
import 'package:ProjectName/core/analytics/analytic.dart';
import 'package:ProjectName/core/analytics/screen_analytics/screen_analytic.dart';

class ViewPagerAnalyticObserver with ScreenAnalyticTracker {
  ViewPagerAnalyticObserver(Analytic analytic) {
    this.analytic = analytic;
  }

  void onViewPagerChanged(
    int prevIdx,
    int currIdx,
    Map<int, String> pageNameIdxMap,
  ) {
    if (prevIdx == currIdx) {
      return;
    }

    late String currPageName;

    if (pageNameIdxMap.containsKey(currIdx)) {
      currPageName = pageNameIdxMap[currIdx]!;

      trackScreen(currPageName);
      if (kDebugMode) {
        print("Curr pager: ${getCurrentScreen()}");
      }
    }
  }
}
