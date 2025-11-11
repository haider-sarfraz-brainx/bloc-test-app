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

  void _addStudent(AddStudent event, Emitter<StudentState> emit) {
    final updated = List<StudentModel>.from(state.students)..add(event.student);
    emit(state.copyWith(students: updated, filteredStudents: updated));
  }

  void _deleteStudent(DeleteStudent event, Emitter<StudentState> emit) {
    final updated = state.students.where((s) => s.id != event.id).toList();
    emit(state.copyWith(students: updated, filteredStudents: updated));
  }

  void _editStudent(EditStudent event, Emitter<StudentState> emit) {
    final updated = state.students.map((s) {
      print("_editStudent kwkw");
      return s.id == event.updatedStudent.id ? event.updatedStudent : s;
    }).toList();
    emit(state.copyWith(students: updated, filteredStudents: updated));
  }

  void _searchStudent(SearchStudent event, Emitter<StudentState> emit) {
    final filtered = state.students
        .where((s) => s.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredStudents: filtered));
  }
}
