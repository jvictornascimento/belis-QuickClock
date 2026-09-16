import 'package:quick_clock/models/work_day.dart';

class WorkDayEditPolicy {
  const WorkDayEditPolicy({DateTime Function()? nowProvider})
    : _nowProvider = nowProvider ?? DateTime.now;

  final DateTime Function() _nowProvider;

  bool canEdit(String date) {
    return date == WorkDay.dateKey(_nowProvider());
  }
}
