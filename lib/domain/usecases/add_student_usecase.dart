import '../../core/usecases/usecase.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class AddStudentUseCase implements UseCase<StudentEntity, StudentEntity> {
  final StudentRepository repository;

  AddStudentUseCase(this.repository);

  @override
  Future<StudentEntity> call(StudentEntity params) {
    return repository.addStudent(params);
  }
}


