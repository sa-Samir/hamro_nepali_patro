import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';

enum ConversionDirection { bsToAd, adToBs }

class ConverterState extends Equatable {
  const ConverterState({
    required this.direction,
    required this.date,
    required this.today,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final ConversionDirection direction;

  /// The chosen date. Stored as BS; the AD side is derived with [BsDate.toAd].
  final BsDate date;
  final BsDate today;

  /// "Days between" calculator.
  final BsDate rangeStart;
  final BsDate rangeEnd;

  int get daysFromToday => today.daysUntil(date);

  int get daysBetween => rangeStart.daysUntil(rangeEnd);

  /// Calendar difference in BS years/months/days between the range ends.
  ({int years, int months, int days}) get rangeBreakdown => bsDifference(rangeStart, rangeEnd);

  ConverterState copyWith({ConversionDirection? direction, BsDate? date, BsDate? rangeStart, BsDate? rangeEnd}) =>
      ConverterState(
        direction: direction ?? this.direction,
        date: date ?? this.date,
        today: today,
        rangeStart: rangeStart ?? this.rangeStart,
        rangeEnd: rangeEnd ?? this.rangeEnd,
      );

  @override
  List<Object?> get props => [direction, date, today, rangeStart, rangeEnd];
}

class ConverterCubit extends Cubit<ConverterState> {
  ConverterCubit({BsDate? today}) : super(_initial(today ?? BsDate.today()));

  static ConverterState _initial(BsDate today) => ConverterState(
    direction: ConversionDirection.bsToAd,
    date: today,
    today: today,
    rangeStart: today,
    rangeEnd: today,
  );

  void setDirection(ConversionDirection direction) => emit(state.copyWith(direction: direction));

  void setBsDate(BsDate date) => emit(state.copyWith(date: date));

  void setAdDate(DateTime date) => emit(state.copyWith(date: BsDate.fromAd(date)));

  void setRangeStart(BsDate date) => emit(state.copyWith(rangeStart: date));

  void setRangeEnd(BsDate date) => emit(state.copyWith(rangeEnd: date));

  void swapRange() => emit(state.copyWith(rangeStart: state.rangeEnd, rangeEnd: state.rangeStart));
}

/// Years, months and days from [from] to [to] counted in BS months, the way
/// ages are usually stated in Nepal. Order-independent.
({int years, int months, int days}) bsDifference(BsDate from, BsDate to) {
  var a = from;
  var b = to;
  if (b.isBefore(a)) (a, b) = (b, a);
  var years = b.year - a.year;
  var months = b.month - a.month;
  var days = b.day - a.day;
  if (days < 0) {
    months -= 1;
    final previous = b.addMonths(-1);
    days += previous.daysInThisMonth;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }
  return (years: years, months: months, days: days);
}
