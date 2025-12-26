import '../../core/usecases/usecase.dart';
import '../repositories/student_repository.dart';

class DeleteStudentUseCase implements UseCase<void, String> {
  final StudentRepository repository;

  DeleteStudentUseCase(this.repository);

  @override
  Future<void> call(String params) {
    return repository.deleteStudent(params);
  }
}


