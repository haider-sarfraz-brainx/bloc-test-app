import '../models/student_model.dart';

abstract class StudentLocalDataSource {
  Future<List<StudentModel>> getStudents();
  Future<StudentModel> addStudent(StudentModel student);
  Future<void> deleteStudent(String id);
  Future<StudentModel> updateStudent(StudentModel student);
}

