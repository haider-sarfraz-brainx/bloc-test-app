import 'package:bloc_test/bloc/student/student_events.dart';
import 'package:bloc_test/bloc/student/student_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/student_model.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {


  StudentBloc() : super(StudentState.initial()) {
    on<AddStudent>(_addStudent);
    on<DeleteStudent>(_deleteStudent);
    on<EditStudent>(_editStudent);
    on<SearchStudent>(_searchStudent);
  }

  Future<void> _addStudent(AddStudent event, Emitter<StudentState> emit) async {
    emit(state.copyWith(loading: true));
    final updated = List<StudentModel>.from(state.students)..add(event.student);
    await Future.delayed(Duration(seconds: 2));
    emit(state.copyWith(loading: false));
    emit(state.copyWith(
      students: updated,
      filteredStudents: updated,
      statusMessage: 'New student added successfully',
    ));
    // Clear the status message after emitting
    emit(state.copyWith(students: updated, filteredStudents: updated, statusMessage: null,));
    event.completer.complete();
  }

  void _deleteStudent(DeleteStudent event, Emitter<StudentState> emit) {
    final updated = state.students.where((s) => s.id != event.id).toList();

    emit(state.copyWith(
      students: updated,
      filteredStudents: updated,
      statusMessage: 'student remove successfully',
    ));
    // Clear the status message after emitting
    emit(state.copyWith(students: updated, filteredStudents: updated, statusMessage: null,));

  }

  void _editStudent(EditStudent event, Emitter<StudentState> emit) {
  state.students.map((s) {
      return s.id == event.updatedStudent.id ? event.updatedStudent : s;
    }).toList();
  }

  void _searchStudent(SearchStudent event, Emitter<StudentState> emit) {
   state.students
        .where((s) => s.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
  }
}
