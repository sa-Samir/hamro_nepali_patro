import 'package:flutter_bloc/flutter_bloc.dart';

import 'calendar_data_service.dart';

/// Emits the applied data revision so screens and widgets rebuild when
/// downloaded calendar data changes month lengths or holidays.
class CalendarDataCubit extends Cubit<int> {
  CalendarDataCubit(this._service) : super(_service.revision);

  final CalendarDataService _service;

  /// Whether a download source is configured for this build.
  bool get canUpdate => _service.source != null;

  /// Returns true when newer data was applied.
  Future<bool> refresh({bool force = false}) async {
    final updated = await _service.refresh(force: force);
    if (updated) emit(_service.revision);
    return updated;
  }
}
