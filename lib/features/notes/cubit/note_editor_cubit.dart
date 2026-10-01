import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bs/bs_date.dart';
import '../models/note.dart';

enum EditorStatus { editing, saving, saved, deleted }

class NoteEditorState extends Equatable {
  const NoteEditorState({required this.draft, this.status = EditorStatus.editing, this.showErrors = false});

  final Note draft;
  final EditorStatus status;

  /// Becomes true after a save attempt so errors aren't shown while typing.
  final bool showErrors;

  bool get isNew => draft.id == null;

  bool get titleMissing => draft.title.trim().isEmpty;

  NoteEditorState copyWith({Note? draft, EditorStatus? status, bool? showErrors}) => NoteEditorState(
    draft: draft ?? this.draft,
    status: status ?? this.status,
    showErrors: showErrors ?? this.showErrors,
  );

  @override
  List<Object?> get props => [draft, status, showErrors];
}

class NoteEditorCubit extends Cubit<NoteEditorState> {
  NoteEditorCubit({
    Note? note,
    BsDate? date,
    required int defaultReminderMinutes,
    required Future<int> Function(Note) save,
    required Future<void> Function(Note) delete,
  }) : _save = save,
       _delete = delete,
       super(
         NoteEditorState(
           draft: note ?? Note(title: '', date: date ?? BsDate.today(), reminderMinutes: defaultReminderMinutes),
         ),
       );

  final Future<int> Function(Note) _save;
  final Future<void> Function(Note) _delete;

  void _edit(Note Function(Note n) change) => emit(state.copyWith(draft: change(state.draft)));

  void setTitle(String value) => _edit((n) => n.copyWith(title: value));

  void setDescription(String value) => _edit((n) => n.copyWith(description: value));

  void setDate(BsDate value) => _edit((n) => n.copyWith(date: value));

  void setRepeat(RepeatRule value) => _edit((n) => n.copyWith(repeat: value));

  void setRemind(bool value) => _edit((n) => n.copyWith(remind: value));

  void setReminderMinutes(int value) => _edit((n) => n.copyWith(reminderMinutes: value));

  void toggleOffset(int days) => _edit((n) {
    final offsets = {...n.reminderOffsets};
    if (!offsets.remove(days)) offsets.add(days);
    return n.copyWith(reminderOffsets: offsets.toList()..sort());
  });

  /// Returns true when the note was saved.
  Future<bool> save() async {
    if (state.titleMissing) {
      emit(state.copyWith(showErrors: true));
      return false;
    }
    emit(state.copyWith(status: EditorStatus.saving));
    final draft = state.draft.copyWith(title: state.draft.title.trim(), description: state.draft.description.trim());
    final id = await _save(draft);
    emit(
      state.copyWith(
        draft: draft.copyWith(id: id),
        status: EditorStatus.saved,
      ),
    );
    return true;
  }

  Future<void> delete() async {
    if (state.isNew) return;
    await _delete(state.draft);
    emit(state.copyWith(status: EditorStatus.deleted));
  }
}
