import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_local_datasource.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDataSource localDataSource;

  StudentRepositoryImpl(this.localDataSource);

  @override
  Future<List<StudentEntity>> getStudents() async {
    final students = await localDataSource.getStudents();
    return students;
  }

  @override
  Future<StudentEntity> addStudent(StudentEntity student) async {
    final studentModel = StudentModel.fromEntity(student);
    return await localDataSource.addStudent(studentModel);
  }

  @override
  Future<void> deleteStudent(String id) async {
    await localDataSource.deleteStudent(id);
  }

  @override
  Future<StudentEntity> updateStudent(StudentEntity student) async {
    final studentModel = StudentModel.fromEntity(student);
    return await localDataSource.updateStudent(studentModel);
  }
}

