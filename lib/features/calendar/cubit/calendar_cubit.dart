import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';

class CalendarState extends Equatable {
  const CalendarState({required this.today, required this.visibleMonth, required this.selected});

  final BsDate today;

  /// First day of the month on screen.
  final BsDate visibleMonth;
  final BsDate selected;

  CalendarState copyWith({BsDate? today, BsDate? visibleMonth, BsDate? selected}) => CalendarState(
    today: today ?? this.today,
    visibleMonth: visibleMonth ?? this.visibleMonth,
    selected: selected ?? this.selected,
  );

  @override
  List<Object?> get props => [today, visibleMonth, selected];
}

/// Months are addressed by a flat index (months since Baisakh of the first
/// supported year) so the calendar can be driven by a PageView.
int monthIndexOf(BsDate date) => (date.year - BsDate.min.year) * 12 + date.month - 1;

BsDate monthAtIndex(int index) => BsDate(BsDate.min.year + index ~/ 12, index % 12 + 1, 1);

final int monthCount = monthIndexOf(BsDate.max) + 1;

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({BsDate Function()? clock})
    : _clock = clock ?? BsDate.today,
      super(_initial((clock ?? BsDate.today)()));

  final BsDate Function() _clock;

  static CalendarState _initial(BsDate today) =>
      CalendarState(today: today, visibleMonth: today.firstOfMonth, selected: today);

  void showMonth(BsDate month) {
    final first = month.firstOfMonth;
    if (first == state.visibleMonth) return;
    // Keep the selection inside the visible month so the day panel matches.
    final selected = state.today.isSameMonth(first) ? state.today : first;
    emit(state.copyWith(visibleMonth: first, selected: selected));
  }

  void nextMonth() {
    if (monthIndexOf(state.visibleMonth) < monthCount - 1) showMonth(state.visibleMonth.addMonths(1));
  }

  void previousMonth() {
    if (monthIndexOf(state.visibleMonth) > 0) showMonth(state.visibleMonth.addMonths(-1));
  }

  void select(BsDate date) => emit(state.copyWith(selected: date, visibleMonth: date.firstOfMonth));

  void goToToday() => emit(_initial(state.today));

  /// Picks up a date change, e.g. when the app resumes after midnight.
  void refreshToday() {
    final today = _clock();
    if (today == state.today) return;
    final wasOnToday = state.selected == state.today;
    emit(wasOnToday ? _initial(today) : state.copyWith(today: today));
  }
}
