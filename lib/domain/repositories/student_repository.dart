import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> getStudents();
  Future<StudentEntity> addStudent(StudentEntity student);
  Future<void> deleteStudent(String id);
  Future<StudentEntity> updateStudent(StudentEntity student);
}

