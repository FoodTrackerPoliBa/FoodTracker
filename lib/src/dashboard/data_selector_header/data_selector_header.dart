import 'package:flutter/material.dart';
import 'package:food_traker/src/dashboard/date_controller.dart';

class DataSelectorHeader extends StatelessWidget {
  const DataSelectorHeader({super.key, required this.controller});
  final DateController controller;

  Future<void> selectManualDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000));

    if (pickedDate != null) {
      controller.setDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: IconButton(
                onPressed: controller.decrementDate,
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => selectManualDate(context),
              onLongPress: () {
                /// Reset the date to today
                controller.setDate(DateTime.now());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, snapshot) {
                      return Text(
                        controller.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: IconButton(
                onPressed: controller.incrementDate,
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
