import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../core/bs/bs_date.dart';
import '../features/notes/models/note.dart';

/// Backup files are plain JSON so they stay readable and portable.
class BackupService {
  static const _format = 'patro-backup';
  static const _version = 1;

  String encode(List<Note> notes) => const JsonEncoder.withIndent('  ').convert({
    'format': _format,
    'version': _version,
    'exportedAt': DateTime.now().toIso8601String(),
    'notes': [
      for (final n in notes)
        {
          'title': n.title,
          'description': n.description,
          'date': n.date.toString(),
          'repeat': n.repeat.name,
          'remind': n.remind,
          'reminderOffsets': n.reminderOffsets,
          'reminderMinutes': n.reminderMinutes,
        },
    ],
  });

  /// Throws [FormatException] if [source] is not a valid backup.
  List<Note> decode(String source) {
    try {
      return _decode(source);
    } on FormatException {
      rethrow;
    } on Object {
      // Wrong field types, bad dates, etc.
      throw const FormatException('Malformed Patro backup');
    }
  }

  List<Note> _decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map<String, dynamic> || json['format'] != _format) {
      throw const FormatException('Not a Patro backup');
    }
    return [
      for (final n in (json['notes'] as List).cast<Map<String, dynamic>>())
        _validated(
          Note(
            title: n['title'] as String,
            description: n['description'] as String? ?? '',
            date: BsDate.parse(n['date'] as String),
            repeat: RepeatRule.values.asNameMap()[n['repeat']] ?? RepeatRule.none,
            remind: n['remind'] as bool? ?? true,
            reminderOffsets: (n['reminderOffsets'] as List? ?? const [0]).cast<int>(),
            reminderMinutes: n['reminderMinutes'] as int? ?? 480,
          ),
        ),
    ];
  }

  /// Lets the user choose where to save the backup. Returns false if cancelled.
  Future<bool> export(List<Note> notes) async {
    final stamp = BsDate.today().toString();
    final uri = await FilePicker.saveFile(
      fileName: 'patro-backup-$stamp.json',
      bytes: Uint8List.fromList(utf8.encode(encode(notes))),
      mimeType: 'application/json',
    );
    return uri != null;
  }

  /// Lets the user pick a backup file. Returns null if cancelled.
  Future<List<Note>?> pickAndRead() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
    if (file == null) return null;
    return decode(await file.xFile.readAsString());
  }

  Note _validated(Note note) {
    if (note.title.trim().isEmpty || !note.date.isValid) {
      throw const FormatException('Invalid note in backup');
    }
    return note;
  }
}
