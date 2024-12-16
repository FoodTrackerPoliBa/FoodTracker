import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/activity.dart';
import 'package:food_traker/src/backend/types/meal_session.dart';
import 'package:food_traker/src/dashboard/hour_distribution/widgets/activity_card.dart';
import 'package:food_traker/src/dashboard/hour_distribution/widgets/add_item.dart';
import 'package:food_traker/src/dashboard/hour_distribution/widgets/food_card.dart';
import 'package:food_traker/src/dashboard/hour_distribution/widgets/hour_summary_card.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

typedef TodayData = Map<int, (List<MealSession>, List<Activity>)>;

class HourDistribution extends StatefulWidget {
  const HourDistribution({super.key, required this.date});
  final DateTime date;
  @override
  State<HourDistribution> createState() => _HourDistributionState();
}

class _HourDistributionState extends State<HourDistribution> {
  final ItemScrollController _scrollController = ItemScrollController();
  late final StreamController<int> _hourStreamController;
  late Stream<int> _hourStream;
  int? lastHour;

  @override
  void initState() {
    super.initState();
    _hourStreamController = StreamController<int>();
    _hourStream = _hourStreamController.stream.asBroadcastStream();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DateTime now = DateTime.now();
      _scrollController.scrollTo(
        index: now.hour,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    _startHourTimer();
  }

  @override
  void dispose() {
    _hourStreamController.close();
    super.dispose();
  }

  void _startHourTimer() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final now = DateTime.now();
      if (now.hour != lastHour) {
        _hourStreamController.add(now.hour);
        lastHour = now.hour;
      }
    });
  }

  bool isCurrentHour(int hour, int currentHour) {
    return currentHour == hour;
  }

  Future<TodayData> getTodayData() async {
    final DateTime now = widget.date;
    final DateTime start = DateTime(now.year, now.month, now.day);
    final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final List<MealSession> meals =
        await backend.getMealSessions(start: start, end: end);
    final List<Activity> activities =
        await backend.getActivities(start: start, end: end);
    final Map<int, (List<MealSession>, List<Activity>)> data = {};
    for (final MealSession meal in meals) {
      final int hour = meal.timestamp.hour;
      if (data.containsKey(hour)) {
        data[hour]!.$1.add(meal);
      } else {
        data[hour] = ([meal], []);
      }
    }
    for (final Activity activity in activities) {
      final int hour = activity.timestamp.hour;
      if (data.containsKey(hour)) {
        data[hour]!.$2.add(activity);
      } else {
        data[hour] = ([], [activity]);
      }
    }
    return data;
  }

  List<Widget> getHourCards(TodayData data, int index) {
    final List<Widget> cards = [];
    final List<MealSession> meals = data[index]?.$1 ?? [];
    final List<Activity> activities = data[index]?.$2 ?? [];
    for (final MealSession meal in meals) {
      cards.add(MealCard(mealSession: meal));
    }
    for (final Activity activity in activities) {
      cards.add(ActivityCard(activity: activity));
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _hourStream,
      initialData: DateTime.now().hour,
      builder: (context, snapshot) {
        final int currentHour = snapshot.data ?? DateTime.now().hour;
        return AnimatedBuilder(
          animation: backend,
          builder: (context, snapshot) {
            return FutureBuilder<TodayData>(
              future: getTodayData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return ScrollablePositionedList.separated(
                  itemScrollController: _scrollController,
                  itemCount: 24,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final List<MealSession> meals =
                        snapshot.data?[index]?.$1 ?? [];
                    final List<Activity> activities =
                        snapshot.data?[index]?.$2 ?? [];
                    return InkWell(
                      onTap: () {
                        final DateTime now = widget.date;
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return AddItem(
                              timeSelected: DateTime(
                                now.year,
                                now.month,
                                now.day,
                                index,
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        key: ValueKey('hour_$index'),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          color: isCurrentHour(index, currentHour)
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null,
                        ),
                        child: Row(
                          children: [
                            HourSummaryCard(
                              meals: meals,
                              activities: activities,
                              index: index,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 67,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: getHourCards(
                                    snapshot.data ?? {},
                                    index,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
