import '../../core/usecases/usecase.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class GetStudentsUseCase implements UseCaseNoParams<List<StudentEntity>> {
  final StudentRepository repository;

  GetStudentsUseCase(this.repository);

  @override
  Future<List<StudentEntity>> call() {
    return repository.getStudents();
  }
}


