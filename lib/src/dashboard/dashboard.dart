import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/gemini_manager.dart';
import 'package:food_traker/src/dashboard/chatbot/chatbox.dart';
import 'package:food_traker/src/dashboard/daily_overview/daily_overview.dart';
import 'package:food_traker/src/dashboard/data_selector_header/data_selector_header.dart';
import 'package:food_traker/src/dashboard/date_controller.dart';
import 'package:food_traker/src/dashboard/hour_distribution/hour_distribution.dart';
import 'package:food_traker/src/dashboard/settings/settings.dart';
import 'package:food_traker/src/utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DateController controller = DateController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                Utils.push(
                    context: context,
                    routeName: 'settings',
                    page: const Settings());
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            DataSelectorHeader(controller: controller),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) =>
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  DailyOverview(day: controller.selectedDate),
                  const SizedBox(height: 20),
                  Expanded(
                      child: HourDistribution(date: controller.selectedDate)),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Utils.push(
              context: context,
              routeName: 'chatbot',
              page: ChatBox(controller: geminiManager.controller));
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
