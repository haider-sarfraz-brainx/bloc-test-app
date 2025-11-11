import 'package:equatable/equatable.dart';
import '../../models/student_model.dart';

class StudentState extends Equatable {
  final List<StudentModel> students;
  final List<StudentModel> filteredStudents;

  const StudentState({
    required this.students,
    required this.filteredStudents,
  });

  factory StudentState.initial() {
    return const StudentState(students: [], filteredStudents: []);
  }

  StudentState copyWith({
    List<StudentModel>? students,
    List<StudentModel>? filteredStudents,
  }) {
    return StudentState(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
    );
  }

  @override
  List<Object?> get props => [students, filteredStudents];
}
