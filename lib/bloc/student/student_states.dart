import 'package:equatable/equatable.dart';
import '../../models/student_model.dart';

class StudentState extends Equatable {
  final List<StudentModel> students;
  final List<StudentModel> filteredStudents;
  final String? statusMessage;
  final bool loading;

  const StudentState({
    required this.students,
    required this.filteredStudents,
    this.statusMessage,
    this.loading = false,
  });

  factory StudentState.initial() {
    return const StudentState(students: [], filteredStudents: [], statusMessage: null, loading: false);
  }

  StudentState copyWith({
    List<StudentModel>? students,
    List<StudentModel>? filteredStudents,
    String? statusMessage,
    bool? loading,
  }) {
    return StudentState(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      statusMessage: statusMessage,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [students, filteredStudents, statusMessage, loading];
}
