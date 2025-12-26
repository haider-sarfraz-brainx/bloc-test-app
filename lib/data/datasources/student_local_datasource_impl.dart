import 'student_local_datasource.dart';
import '../models/student_model.dart';

class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final List<StudentModel> _students = [];

  @override
  Future<List<StudentModel>> getStudents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_students);
  }

  @override
  Future<StudentModel> addStudent(StudentModel student) async {
    await Future.delayed(const Duration(seconds: 2));
    _students.add(student);
    return student;
  }

  @override
  Future<void> deleteStudent(String id) async {
    _students.removeWhere((student) => student.id == id);
  }

  @override
  Future<StudentModel> updateStudent(StudentModel student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      return student;
    }
    throw Exception('Student not found');
  }
}

