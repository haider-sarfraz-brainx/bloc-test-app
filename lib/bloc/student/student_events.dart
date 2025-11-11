import 'package:equatable/equatable.dart';
import '../../models/student_model.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class AddStudent extends StudentEvent {
  final StudentModel student;
  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends StudentEvent {
  final String id;
  const DeleteStudent(this.id);

  @override
  List<Object?> get props => [id];
}

class EditStudent extends StudentEvent {
  final StudentModel updatedStudent;
  const EditStudent(this.updatedStudent);

  @override
  List<Object?> get props => [updatedStudent];
}

class SearchStudent extends StudentEvent {
  final String query;
  const SearchStudent(this.query);

  @override
  List<Object?> get props => [query];
}
