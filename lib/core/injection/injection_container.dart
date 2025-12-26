import '../../data/datasources/student_local_datasource.dart';
import '../../data/datasources/student_local_datasource_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/add_student_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import '../../presentation/bloc/student/student_bloc.dart';

class InjectionContainer {
  static StudentBloc getStudentBloc() {
    final StudentLocalDataSource localDataSource =
        StudentLocalDataSourceImpl();
    final StudentRepository repository =
        StudentRepositoryImpl(localDataSource);
    final GetStudentsUseCase getStudentsUseCase =
        GetStudentsUseCase(repository);
    final AddStudentUseCase addStudentUseCase = AddStudentUseCase(repository);
    final DeleteStudentUseCase deleteStudentUseCase =
        DeleteStudentUseCase(repository);
    final UpdateStudentUseCase updateStudentUseCase =
        UpdateStudentUseCase(repository);

    return StudentBloc(
      getStudentsUseCase: getStudentsUseCase,
      addStudentUseCase: addStudentUseCase,
      deleteStudentUseCase: deleteStudentUseCase,
      updateStudentUseCase: updateStudentUseCase,
    );
  }
}

