import '../../core/usecases/usecase.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class UpdateStudentUseCase implements UseCase<StudentEntity, StudentEntity> {
  final StudentRepository repository;

  UpdateStudentUseCase(this.repository);

  @override
  Future<StudentEntity> call(StudentEntity params) {
    return repository.updateStudent(params);
  }
}


