import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/settings_repository.dart';
import '../models/app_settings.dart';

class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.load());

  final SettingsRepository _repository;

  /// Applies [change] to the current settings and persists the result.
  Future<void> update(AppSettings Function(AppSettings s) change) async {
    final next = change(state);
    if (next == state) return;
    emit(next);
    await _repository.save(next);
  }

  /// Switching language also switches digits, which is what most people want;
  /// digits can still be changed on their own afterwards.
  Future<void> setLanguage(AppLanguage language) => update(
    (s) => s.copyWith(
      language: language,
      numerals: language == AppLanguage.ne ? NumeralStyle.devanagari : NumeralStyle.western,
    ),
  );
}
