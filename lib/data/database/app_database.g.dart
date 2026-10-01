// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bsYearMeta = const VerificationMeta('bsYear');
  @override
  late final GeneratedColumn<int> bsYear = GeneratedColumn<int>(
    'bs_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bsMonthMeta = const VerificationMeta('bsMonth');
  @override
  late final GeneratedColumn<int> bsMonth = GeneratedColumn<int>(
    'bs_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bsDayMeta = const VerificationMeta('bsDay');
  @override
  late final GeneratedColumn<int> bsDay = GeneratedColumn<int>(
    'bs_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _remindMeta = const VerificationMeta('remind');
  @override
  late final GeneratedColumn<bool> remind = GeneratedColumn<bool>(
    'remind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("remind" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderOffsetsMeta = const VerificationMeta('reminderOffsets');
  @override
  late final GeneratedColumn<String> reminderOffsets = GeneratedColumn<String>(
    'reminder_offsets',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta('reminderMinutes');
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    bsYear,
    bsMonth,
    bsDay,
    repeat,
    remind,
    reminderOffsets,
    reminderMinutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('bs_year')) {
      context.handle(_bsYearMeta, bsYear.isAcceptableOrUnknown(data['bs_year']!, _bsYearMeta));
    } else if (isInserting) {
      context.missing(_bsYearMeta);
    }
    if (data.containsKey('bs_month')) {
      context.handle(_bsMonthMeta, bsMonth.isAcceptableOrUnknown(data['bs_month']!, _bsMonthMeta));
    } else if (isInserting) {
      context.missing(_bsMonthMeta);
    }
    if (data.containsKey('bs_day')) {
      context.handle(_bsDayMeta, bsDay.isAcceptableOrUnknown(data['bs_day']!, _bsDayMeta));
    } else if (isInserting) {
      context.missing(_bsDayMeta);
    }
    if (data.containsKey('repeat')) {
      context.handle(_repeatMeta, repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta));
    }
    if (data.containsKey('remind')) {
      context.handle(_remindMeta, remind.isAcceptableOrUnknown(data['remind']!, _remindMeta));
    }
    if (data.containsKey('reminder_offsets')) {
      context.handle(
        _reminderOffsetsMeta,
        reminderOffsets.isAcceptableOrUnknown(data['reminder_offsets']!, _reminderOffsetsMeta),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(data['reminder_minutes']!, _reminderMinutesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      bsYear: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}bs_year'])!,
      bsMonth: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}bs_month'])!,
      bsDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}bs_day'])!,
      repeat: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}repeat'])!,
      remind: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}remind'])!,
      reminderOffsets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_offsets'],
      )!,
      reminderMinutes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reminder_minutes'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final int id;
  final String title;
  final String description;
  final int bsYear;
  final int bsMonth;
  final int bsDay;

  /// Name of a `RepeatRule` value.
  final String repeat;
  final bool remind;

  /// Comma separated days-before list, e.g. "0,1".
  final String reminderOffsets;
  final int reminderMinutes;
  final DateTime createdAt;
  const NoteRow({
    required this.id,
    required this.title,
    required this.description,
    required this.bsYear,
    required this.bsMonth,
    required this.bsDay,
    required this.repeat,
    required this.remind,
    required this.reminderOffsets,
    required this.reminderMinutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['bs_year'] = Variable<int>(bsYear);
    map['bs_month'] = Variable<int>(bsMonth);
    map['bs_day'] = Variable<int>(bsDay);
    map['repeat'] = Variable<String>(repeat);
    map['remind'] = Variable<bool>(remind);
    map['reminder_offsets'] = Variable<String>(reminderOffsets);
    map['reminder_minutes'] = Variable<int>(reminderMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      bsYear: Value(bsYear),
      bsMonth: Value(bsMonth),
      bsDay: Value(bsDay),
      repeat: Value(repeat),
      remind: Value(remind),
      reminderOffsets: Value(reminderOffsets),
      reminderMinutes: Value(reminderMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      bsYear: serializer.fromJson<int>(json['bsYear']),
      bsMonth: serializer.fromJson<int>(json['bsMonth']),
      bsDay: serializer.fromJson<int>(json['bsDay']),
      repeat: serializer.fromJson<String>(json['repeat']),
      remind: serializer.fromJson<bool>(json['remind']),
      reminderOffsets: serializer.fromJson<String>(json['reminderOffsets']),
      reminderMinutes: serializer.fromJson<int>(json['reminderMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'bsYear': serializer.toJson<int>(bsYear),
      'bsMonth': serializer.toJson<int>(bsMonth),
      'bsDay': serializer.toJson<int>(bsDay),
      'repeat': serializer.toJson<String>(repeat),
      'remind': serializer.toJson<bool>(remind),
      'reminderOffsets': serializer.toJson<String>(reminderOffsets),
      'reminderMinutes': serializer.toJson<int>(reminderMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NoteRow copyWith({
    int? id,
    String? title,
    String? description,
    int? bsYear,
    int? bsMonth,
    int? bsDay,
    String? repeat,
    bool? remind,
    String? reminderOffsets,
    int? reminderMinutes,
    DateTime? createdAt,
  }) => NoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    bsYear: bsYear ?? this.bsYear,
    bsMonth: bsMonth ?? this.bsMonth,
    bsDay: bsDay ?? this.bsDay,
    repeat: repeat ?? this.repeat,
    remind: remind ?? this.remind,
    reminderOffsets: reminderOffsets ?? this.reminderOffsets,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    createdAt: createdAt ?? this.createdAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present ? data.description.value : this.description,
      bsYear: data.bsYear.present ? data.bsYear.value : this.bsYear,
      bsMonth: data.bsMonth.present ? data.bsMonth.value : this.bsMonth,
      bsDay: data.bsDay.present ? data.bsDay.value : this.bsDay,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      remind: data.remind.present ? data.remind.value : this.remind,
      reminderOffsets: data.reminderOffsets.present ? data.reminderOffsets.value : this.reminderOffsets,
      reminderMinutes: data.reminderMinutes.present ? data.reminderMinutes.value : this.reminderMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('bsYear: $bsYear, ')
          ..write('bsMonth: $bsMonth, ')
          ..write('bsDay: $bsDay, ')
          ..write('repeat: $repeat, ')
          ..write('remind: $remind, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    bsYear,
    bsMonth,
    bsDay,
    repeat,
    remind,
    reminderOffsets,
    reminderMinutes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.bsYear == this.bsYear &&
          other.bsMonth == this.bsMonth &&
          other.bsDay == this.bsDay &&
          other.repeat == this.repeat &&
          other.remind == this.remind &&
          other.reminderOffsets == this.reminderOffsets &&
          other.reminderMinutes == this.reminderMinutes &&
          other.createdAt == this.createdAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> bsYear;
  final Value<int> bsMonth;
  final Value<int> bsDay;
  final Value<String> repeat;
  final Value<bool> remind;
  final Value<String> reminderOffsets;
  final Value<int> reminderMinutes;
  final Value<DateTime> createdAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.bsYear = const Value.absent(),
    this.bsMonth = const Value.absent(),
    this.bsDay = const Value.absent(),
    this.repeat = const Value.absent(),
    this.remind = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int bsYear,
    required int bsMonth,
    required int bsDay,
    this.repeat = const Value.absent(),
    this.remind = const Value.absent(),
    this.reminderOffsets = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       bsYear = Value(bsYear),
       bsMonth = Value(bsMonth),
       bsDay = Value(bsDay);
  static Insertable<NoteRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? bsYear,
    Expression<int>? bsMonth,
    Expression<int>? bsDay,
    Expression<String>? repeat,
    Expression<bool>? remind,
    Expression<String>? reminderOffsets,
    Expression<int>? reminderMinutes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (bsYear != null) 'bs_year': bsYear,
      if (bsMonth != null) 'bs_month': bsMonth,
      if (bsDay != null) 'bs_day': bsDay,
      if (repeat != null) 'repeat': repeat,
      if (remind != null) 'remind': remind,
      if (reminderOffsets != null) 'reminder_offsets': reminderOffsets,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? bsYear,
    Value<int>? bsMonth,
    Value<int>? bsDay,
    Value<String>? repeat,
    Value<bool>? remind,
    Value<String>? reminderOffsets,
    Value<int>? reminderMinutes,
    Value<DateTime>? createdAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bsYear: bsYear ?? this.bsYear,
      bsMonth: bsMonth ?? this.bsMonth,
      bsDay: bsDay ?? this.bsDay,
      repeat: repeat ?? this.repeat,
      remind: remind ?? this.remind,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (bsYear.present) {
      map['bs_year'] = Variable<int>(bsYear.value);
    }
    if (bsMonth.present) {
      map['bs_month'] = Variable<int>(bsMonth.value);
    }
    if (bsDay.present) {
      map['bs_day'] = Variable<int>(bsDay.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (remind.present) {
      map['remind'] = Variable<bool>(remind.value);
    }
    if (reminderOffsets.present) {
      map['reminder_offsets'] = Variable<String>(reminderOffsets.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('bsYear: $bsYear, ')
          ..write('bsMonth: $bsMonth, ')
          ..write('bsDay: $bsDay, ')
          ..write('repeat: $repeat, ')
          ..write('remind: $remind, ')
          ..write('reminderOffsets: $reminderOffsets, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [notes];
}

typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required String title,
      Value<String> description,
      required int bsYear,
      required int bsMonth,
      required int bsDay,
      Value<String> repeat,
      Value<bool> remind,
      Value<String> reminderOffsets,
      Value<int> reminderMinutes,
      Value<DateTime> createdAt,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> description,
      Value<int> bsYear,
      Value<int> bsMonth,
      Value<int> bsDay,
      Value<String> repeat,
      Value<bool> remind,
      Value<String> reminderOffsets,
      Value<int> reminderMinutes,
      Value<DateTime> createdAt,
    });

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bsYear =>
      $composableBuilder(column: $table.bsYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bsMonth =>
      $composableBuilder(column: $table.bsMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bsDay => $composableBuilder(column: $table.bsDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderOffsets =>
      $composableBuilder(column: $table.reminderOffsets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinutes =>
      $composableBuilder(column: $table.reminderMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bsYear =>
      $composableBuilder(column: $table.bsYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bsMonth =>
      $composableBuilder(column: $table.bsMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bsDay =>
      $composableBuilder(column: $table.bsDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderOffsets =>
      $composableBuilder(column: $table.reminderOffsets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinutes =>
      $composableBuilder(column: $table.reminderMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get bsYear => $composableBuilder(column: $table.bsYear, builder: (column) => column);

  GeneratedColumn<int> get bsMonth => $composableBuilder(column: $table.bsMonth, builder: (column) => column);

  GeneratedColumn<int> get bsDay => $composableBuilder(column: $table.bsDay, builder: (column) => column);

  GeneratedColumn<String> get repeat => $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<bool> get remind => $composableBuilder(column: $table.remind, builder: (column) => column);

  GeneratedColumn<String> get reminderOffsets =>
      $composableBuilder(column: $table.reminderOffsets, builder: (column) => column);

  GeneratedColumn<int> get reminderMinutes =>
      $composableBuilder(column: $table.reminderMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> bsYear = const Value.absent(),
                Value<int> bsMonth = const Value.absent(),
                Value<int> bsDay = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<String> reminderOffsets = const Value.absent(),
                Value<int> reminderMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                description: description,
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDay: bsDay,
                repeat: repeat,
                remind: remind,
                reminderOffsets: reminderOffsets,
                reminderMinutes: reminderMinutes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                required int bsYear,
                required int bsMonth,
                required int bsDay,
                Value<String> repeat = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<String> reminderOffsets = const Value.absent(),
                Value<int> reminderMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                description: description,
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDay: bsDay,
                repeat: repeat,
                remind: remind,
                reminderOffsets: reminderOffsets,
                reminderMinutes: reminderMinutes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  BaseReferences<_$AppDatabase, $NotesTable, NoteRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes => $$NotesTableTableManager(_db, _db.notes);
}
