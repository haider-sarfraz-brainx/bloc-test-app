import 'package:bloc_test/bloc/student/student_events.dart';
import 'package:bloc_test/bloc/student/student_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant/app_constant.dart';
import '../../local_storage/hive_helper.dart';
import '../../models/student_model.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc() : super(StudentState.initial()) {
    on<LoadStudents>(_loadStudents);
    on<AddStudent>(_addStudent);
    on<DeleteStudent>(_deleteStudent);
    on<EditStudent>(_editStudent);
    on<SearchStudent>(_searchStudent);
  }

  Future<void> _loadStudents(
    LoadStudents event,
    Emitter<StudentState> emit,
  ) async {
    List<StudentModel> students = [];
    try {
      final studentsData = await HiveHelper.get(
        AppConstant.studentBox,
        AppConstant.studentsKey,
        defaultValue: <Map<String, dynamic>>[],
      );
      if (studentsData is List) {
        for (var element in studentsData) {
          if (element != null && element is Map) {
            try {
              final studentMap = Map<String, dynamic>.from(element);
              if (studentMap.containsKey('id') && 
                  studentMap.containsKey('name') && 
                  studentMap.containsKey('email') && 
                  studentMap.containsKey('phoneNumber')) {
                students.add(StudentModel.fromMap(studentMap));
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
    } catch (e) {
      students = [];
    }
    emit(state.copyWith(students: students, filteredStudents: students));
  }

  Future<void> _addStudent(AddStudent event, Emitter<StudentState> emit) async {
    final updated = List<StudentModel>.from(state.students)..add(event.student);
    final studentsList = updated.map((s) => s.toMap()).toList();
    await HiveHelper.put(
      AppConstant.studentBox,
      AppConstant.studentsKey,
      studentsList,
    );
    emit(state.copyWith(students: updated, filteredStudents: updated));
  }

  Future<void> _deleteStudent(
    DeleteStudent event,
    Emitter<StudentState> emit,
  ) async {
    final updated = state.students.where((s) => s.id != event.id).toList();
    final studentsList = updated.map((s) => s.toMap()).toList();
    await HiveHelper.put(
      AppConstant.studentBox,
      AppConstant.studentsKey,
      studentsList,
    );
    emit(state.copyWith(students: updated, filteredStudents: updated));
  }

  Future<void> _editStudent(
    EditStudent event,
    Emitter<StudentState> emit,
  ) async {
    final updated =
        state.students.map((s) {
          return s.id == event.updatedStudent.id ? event.updatedStudent : s;
        }).toList();
    final studentsList = updated.map((s) => s.toMap()).toList();
    await HiveHelper.put(
      AppConstant.studentBox,
      AppConstant.studentsKey,
      studentsList,
    );
    emit(state.copyWith(students: updated, filteredStudents: updated));
  }

  void _searchStudent(SearchStudent event, Emitter<StudentState> emit) {
    final filtered =
        state.students
            .where(
              (s) => s.name.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();
    emit(state.copyWith(filteredStudents: filtered));
  }
}
