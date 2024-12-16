import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Increment the date by one day.
  void incrementDate() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  /// Decrement the date by one day.
  void decrementDate() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  @override
  String toString() {
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }
}
