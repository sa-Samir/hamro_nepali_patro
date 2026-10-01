import 'package:drift/drift.dart';

import '../../core/bs/bs_date.dart';
import '../../features/notes/models/note.dart';
import '../database/app_database.dart';

class NotesRepository {
  NotesRepository(this._db);

  final AppDatabase _db;

  Stream<List<Note>> watchAll() =>
      (_db.select(_db.notes)..orderBy([
            (t) => OrderingTerm.asc(t.bsYear),
            (t) => OrderingTerm.asc(t.bsMonth),
            (t) => OrderingTerm.asc(t.bsDay),
          ]))
          .watch()
          .map((rows) => rows.map(_toNote).toList());

  Future<List<Note>> getAll() async => (await _db.select(_db.notes).get()).map(_toNote).toList();

  /// Inserts or updates [note] and returns its id.
  Future<int> save(Note note) async {
    final companion = _toCompanion(note);
    if (note.id == null) return _db.into(_db.notes).insert(companion);
    await (_db.update(_db.notes)..where((t) => t.id.equals(note.id!))).write(companion);
    return note.id!;
  }

  /// Re-inserts a previously deleted note, keeping its id.
  Future<void> restore(Note note) => _db.into(_db.notes).insert(_toCompanion(note).copyWith(id: Value(note.id!)));

  Future<void> delete(int id) => (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();

  Future<void> insertAll(List<Note> notes) =>
      _db.batch((b) => b.insertAll(_db.notes, [for (final n in notes) _toCompanion(n)]));

  Note _toNote(NoteRow row) => Note(
    id: row.id,
    title: row.title,
    description: row.description,
    date: BsDate(row.bsYear, row.bsMonth, row.bsDay),
    repeat: RepeatRule.values.asNameMap()[row.repeat] ?? RepeatRule.none,
    remind: row.remind,
    reminderOffsets: row.reminderOffsets.isEmpty ? const [] : row.reminderOffsets.split(',').map(int.parse).toList(),
    reminderMinutes: row.reminderMinutes,
  );

  NotesCompanion _toCompanion(Note note) => NotesCompanion(
    title: Value(note.title),
    description: Value(note.description),
    bsYear: Value(note.date.year),
    bsMonth: Value(note.date.month),
    bsDay: Value(note.date.day),
    repeat: Value(note.repeat.name),
    remind: Value(note.remind),
    reminderOffsets: Value((note.reminderOffsets.toSet().toList()..sort()).join(',')),
    reminderMinutes: Value(note.reminderMinutes),
  );
}
