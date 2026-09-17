import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/estimate.dart';
import 'package:quick_clock/models/work_day.dart';

class MonthReport {
  const MonthReport({
    required this.companyName,
    required this.month,
    required this.workDays,
    this.additionalServices = const [],
    this.approvedEstimates = const [],
    required this.halfDayValueCents,
  });

  final String companyName;
  final String month;
  final List<WorkDay> workDays;
  final List<AdditionalService> additionalServices;
  final List<Estimate> approvedEstimates;
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

  int get approvedEstimatesValueCents {
    return approvedEstimates.fold(
      0,
      (total, estimate) => total + estimate.valueCents,
    );
  }

  int get totalValueCents {
    return workDaysValueCents +
        additionalServicesValueCents +
        approvedEstimatesValueCents;
  }
}
