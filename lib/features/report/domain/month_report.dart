import 'package:ponto_eletronico/models/additional_service.dart';
import 'package:ponto_eletronico/models/work_day.dart';

class MonthReport {
  const MonthReport({
    required this.month,
    required this.workDays,
    this.additionalServices = const [],
    required this.halfDayValueCents,
  });

  final String month;
  final List<WorkDay> workDays;
  final List<AdditionalService> additionalServices;
  final int halfDayValueCents;

  int get workedDays => workDays.length;

  int get workedPeriods {
    return workDays.fold(0, (total, workDay) {
      final before = workDay.workedBeforeLunch ? 1 : 0;
      final after = workDay.workedAfterLunch ? 1 : 0;

      return total + before + after;
    });
  }

  int get workDaysValueCents => workedPeriods * halfDayValueCents;

  int get additionalServicesValueCents {
    return additionalServices.fold(
      0,
      (total, service) => total + service.valueCents,
    );
  }

  int get totalValueCents => workDaysValueCents + additionalServicesValueCents;
}
