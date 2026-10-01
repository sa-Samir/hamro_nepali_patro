import 'package:flutter_test/flutter_test.dart';
import 'package:patro/core/bs/bs_date.dart';
import 'package:patro/features/notes/models/note.dart';
import 'package:patro/services/backup_service.dart';

void main() {
  final service = BackupService();

  test('round-trips notes without ids', () {
    const note = Note(
      id: 3,
      title: 'Tihar shopping',
      description: 'Diyo, sweets',
      date: BsDate(2083, 7, 20),
      repeat: RepeatRule.yearlyBs,
      reminderOffsets: [1, 3],
      reminderMinutes: 600,
    );
    final decoded = service.decode(service.encode([note]));
    final restored = decoded.single;
    expect(restored.id, isNull);
    expect(restored.copyWith(id: 3), note);
  });

  test('rejects foreign or malformed files', () {
    expect(() => service.decode('{"hello": 1}'), throwsFormatException);
    expect(() => service.decode('not json'), throwsFormatException);
    expect(
      () => service.decode('{"format":"patro-backup","notes":[{"title":"x","date":"2083-06-40"}]}'),
      throwsFormatException,
    );
    expect(() => service.decode('{"format":"patro-backup","notes":[{"title":5}]}'), throwsFormatException);
  });
}
