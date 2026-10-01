import '../../core/bs/bs_date.dart';

class Holiday {
  const Holiday({
    required this.date,
    required this.titleEn,
    required this.titleNe,
    required this.isPublicHoliday,
    this.scope,
  });

  factory Holiday.fromJson(int year, Map<String, dynamic> json) => Holiday(
    date: BsDate(year, json['month'] as int, json['day'] as int),
    titleEn: json['en'] as String,
    titleNe: json['ne'] as String,
    isPublicHoliday: json['holiday'] as bool? ?? false,
    scope: json['scope'] as String?,
  );

  final BsDate date;
  final String titleEn;
  final String titleNe;

  /// Nationwide day off.
  final bool isPublicHoliday;

  /// Set when the holiday applies to a group only, e.g. "women".
  final String? scope;
}

/// Parses one year's `{"events": [...]}` object, skipping invalid dates.
/// [monthLengths] validates against that year's lengths instead of the
/// current table (used for downloaded corrections).
List<Holiday> parseHolidayYear(int year, Map<String, dynamic> json, {List<int>? monthLengths}) {
  bool valid(BsDate d) => monthLengths == null
      ? d.isValid
      : d.month >= 1 && d.month <= 12 && d.day >= 1 && d.day <= monthLengths[d.month - 1];
  return [
    for (final e in (json['events'] as List).cast<Map<String, dynamic>>())
      if (Holiday.fromJson(year, e) case final h when valid(h.date)) h,
  ];
}
