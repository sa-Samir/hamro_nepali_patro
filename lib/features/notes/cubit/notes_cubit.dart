import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notes_repository.dart';
import '../models/note.dart';

class NotesState extends Equatable {
  const NotesState({this.notes = const [], this.loaded = false});

  final List<Note> notes;
  final bool loaded;

  @override
  List<Object?> get props => [notes, loaded];
}

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository) : super(const NotesState()) {
    _subscription = _repository.watchAll().listen((notes) => emit(NotesState(notes: notes, loaded: true)));
  }

  final NotesRepository _repository;
  late final StreamSubscription<List<Note>> _subscription;

  Future<int> save(Note note) => _repository.save(note);

  Future<void> delete(Note note) => _repository.delete(note.id!);

  /// Re-inserts a deleted note (undo).
  Future<void> restore(Note note) => _repository.restore(note);

  Future<void> importAll(List<Note> notes) => _repository.insertAll(notes);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
