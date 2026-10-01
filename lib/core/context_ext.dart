import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/settings/cubit/settings_cubit.dart';
import '../l10n/app_localizations.dart';
import 'bs/date_formatter.dart';

extension AppContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Date/number formatter for the current settings. Rebuilds the caller
  /// when language or digits change.
  DateFormatter get fmt => DateFormatter.of(watch<SettingsCubit>().state);
}
