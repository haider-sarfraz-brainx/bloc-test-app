import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/add_student_usecase.dart';
import '../../../domain/usecases/delete_student_usecase.dart';
import '../../../domain/usecases/get_students_usecase.dart';
import '../../../domain/usecases/update_student_usecase.dart';
import 'student_events.dart';
import 'student_states.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentsUseCase getStudentsUseCase;
  final AddStudentUseCase addStudentUseCase;
  final DeleteStudentUseCase deleteStudentUseCase;
  final UpdateStudentUseCase updateStudentUseCase;

  StudentBloc({
    required this.getStudentsUseCase,
    required this.addStudentUseCase,
    required this.deleteStudentUseCase,
    required this.updateStudentUseCase,
  }) : super(StudentState.initial()) {
    on<LoadStudentsEvent>(_onLoadStudents);
    on<AddStudentEvent>(_onAddStudent);
    on<DeleteStudentEvent>(_onDeleteStudent);
    on<UpdateStudentEvent>(_onUpdateStudent);
    on<SearchStudentEvent>(_onSearchStudent);
  }

  Future<void> _onLoadStudents(
    LoadStudentsEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final students = await getStudentsUseCase();
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        statusMessage: 'Failed to load students: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddStudent(
    AddStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      await addStudentUseCase(event.student);
      final students = await getStudentsUseCase();
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        loading: false,
        statusMessage: 'Student added successfully',
      ));
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        statusMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        statusMessage: 'Failed to add student: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await deleteStudentUseCase(event.id);
      final students = await getStudentsUseCase();
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        statusMessage: 'Student removed successfully',
      ));
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        statusMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        statusMessage: 'Failed to delete student: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudentEvent event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      await updateStudentUseCase(event.student);
      final students = await getStudentsUseCase();
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        loading: false,
        statusMessage: 'Student updated successfully',
      ));
      emit(state.copyWith(
        students: students,
        filteredStudents: students,
        statusMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        statusMessage: 'Failed to update student: ${e.toString()}',
      ));
    }
  }

  void _onSearchStudent(
    SearchStudentEvent event,
    Emitter<StudentState> emit,
  ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredStudents: state.students));
      return;
    }
    final filtered = state.students
        .where((student) =>
            student.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredStudents: filtered));
  }
}

