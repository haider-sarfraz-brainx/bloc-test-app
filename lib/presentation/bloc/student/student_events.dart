import 'package:equatable/equatable.dart';
import '../../../domain/entities/student_entity.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudentsEvent extends StudentEvent {
  const LoadStudentsEvent();
}

class AddStudentEvent extends StudentEvent {
  final StudentEntity student;
  const AddStudentEvent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudentEvent extends StudentEvent {
  final String id;
  const DeleteStudentEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateStudentEvent extends StudentEvent {
  final StudentEntity student;
  const UpdateStudentEvent(this.student);

  @override
  List<Object?> get props => [student];
}

class SearchStudentEvent extends StudentEvent {
  final String query;
  const SearchStudentEvent(this.query);

  @override
  List<Object?> get props => [query];
}


