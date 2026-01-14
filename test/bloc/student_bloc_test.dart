import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc/student/student_bloc.dart';
import 'package:bloc_test/bloc/student/student_events.dart';
import 'package:bloc_test/bloc/student/student_states.dart';
import 'package:bloc_test/models/student_model.dart';

void main() {
  group('StudentBloc', () {
    late StudentBloc studentBloc;
    
    setUp(() {
      studentBloc = StudentBloc();
    });

    tearDown(() {
      studentBloc.close();
    });

    test('initial state should be empty', () {
      expect(studentBloc.state.students, isEmpty);
      expect(studentBloc.state.filteredStudents, isEmpty);
    });

    test('adds a student', () async {
      const student = StudentModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '1234567890',
      );

      studentBloc.add(const AddStudent(student));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.length, 1);
      expect(studentBloc.state.students.first.name, 'John Doe');
    });

    test('adds multiple students', () async {
      const student1 = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'Jane', email: 'jane@example.com', phoneNumber: '222');

      studentBloc.add(const AddStudent(student1));
      await studentBloc.stream.first;
      studentBloc.add(const AddStudent(student2));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.length, 2);
    });

    test('deletes a student', () async {
      const student1 = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'Jane', email: 'jane@example.com', phoneNumber: '222');

      studentBloc.add(const AddStudent(student1));
      studentBloc.add(const AddStudent(student2));
      await studentBloc.stream.skip(1).first;

      studentBloc.add(const DeleteStudent('1'));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.length, 1);
      expect(studentBloc.state.students.first.id, '2');
    });

    test('edits a student', () async {
      const original = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const updated = StudentModel(id: '1', name: 'Johnny', email: 'johnny@example.com', phoneNumber: '222');

      studentBloc.add(const AddStudent(original));
      await studentBloc.stream.first;

      studentBloc.add(const EditStudent(updated));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.first.name, 'Johnny');
      expect(studentBloc.state.students.first.email, 'johnny@example.com');
    });

    test('searches students by name', () async {
      const student1 = StudentModel(id: '1', name: 'John Doe', email: 'john@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'Jane Smith', email: 'jane@example.com', phoneNumber: '222');
      const student3 = StudentModel(id: '3', name: 'Bob Johnson', email: 'bob@example.com', phoneNumber: '333');

      studentBloc.add(const AddStudent(student1));
      studentBloc.add(const AddStudent(student2));
      studentBloc.add(const AddStudent(student3));
      await studentBloc.stream.skip(2).first;

      studentBloc.add(const SearchStudent('john'));
      await studentBloc.stream.first;

      expect(studentBloc.state.filteredStudents.length, 2);
      expect(studentBloc.state.students.length, 3);
    });

    test('search is case insensitive', () async {
      const student = StudentModel(id: '1', name: 'John Doe', email: 'john@example.com', phoneNumber: '111');

      studentBloc.add(const AddStudent(student));
      await studentBloc.stream.first;

      studentBloc.add(const SearchStudent('JOHN'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(studentBloc.state.filteredStudents.length, 1);
    });

    test('empty search returns all students', () async {
      const student1 = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'Jane', email: 'jane@example.com', phoneNumber: '222');

      studentBloc.add(const AddStudent(student1));
      studentBloc.add(const AddStudent(student2));
      await studentBloc.stream.skip(1).first;

      studentBloc.add(const SearchStudent(''));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(studentBloc.state.filteredStudents.length, 2);
    });

    test('no match returns empty filtered list', () async {
      const student = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');

      studentBloc.add(const AddStudent(student));
      await studentBloc.stream.first;

      studentBloc.add(const SearchStudent('xyz'));
      await studentBloc.stream.first;

      expect(studentBloc.state.filteredStudents, isEmpty);
      expect(studentBloc.state.students.length, 1);
    });

    test('students and filteredStudents sync after add', () async {
      const student = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');

      studentBloc.add(const AddStudent(student));
      await studentBloc.stream.first;

      expect(studentBloc.state.students, studentBloc.state.filteredStudents);
    });

    test('students and filteredStudents sync after delete', () async {
      const student = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');

      studentBloc.add(const AddStudent(student));
      await studentBloc.stream.first;
      studentBloc.add(const DeleteStudent('1'));
      await studentBloc.stream.first;

      expect(studentBloc.state.students, studentBloc.state.filteredStudents);
      expect(studentBloc.state.students, isEmpty);
    });

    test('edit preserves other students', () async {
      const student1 = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'Jane', email: 'jane@example.com', phoneNumber: '222');
      const updated1 = StudentModel(id: '1', name: 'Johnny', email: 'johnny@example.com', phoneNumber: '333');

      studentBloc.add(const AddStudent(student1));
      studentBloc.add(const AddStudent(student2));
      await studentBloc.stream.skip(1).first;

      studentBloc.add(const EditStudent(updated1));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.length, 2);
      expect(studentBloc.state.students[1].name, 'Jane');
    });

    test('multiple edits of same student', () async {
      const original = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const edit1 = StudentModel(id: '1', name: 'Johnny', email: 'john@example.com', phoneNumber: '111');
      const edit2 = StudentModel(id: '1', name: 'Jonathan', email: 'john@example.com', phoneNumber: '111');

      studentBloc.add(const AddStudent(original));
      await studentBloc.stream.first;
      studentBloc.add(const EditStudent(edit1));
      await studentBloc.stream.first;
      studentBloc.add(const EditStudent(edit2));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.first.name, 'Jonathan');
    });

    test('delete from middle of list', () async {
      const student1 = StudentModel(id: '1', name: 'A', email: 'a@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'B', email: 'b@example.com', phoneNumber: '222');
      const student3 = StudentModel(id: '3', name: 'C', email: 'c@example.com', phoneNumber: '333');

      studentBloc.add(const AddStudent(student1));
      studentBloc.add(const AddStudent(student2));
      studentBloc.add(const AddStudent(student3));
      await studentBloc.stream.skip(2).first;

      studentBloc.add(const DeleteStudent('2'));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.length, 2);
      expect(studentBloc.state.students[0].id, '1');
      expect(studentBloc.state.students[1].id, '3');
    });

    test('add edit search sequence', () async {
      const original = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const edited = StudentModel(id: '1', name: 'Johnny', email: 'john@example.com', phoneNumber: '111');

      studentBloc.add(const AddStudent(original));
      await studentBloc.stream.first;
      studentBloc.add(const EditStudent(edited));
      await studentBloc.stream.first;
      studentBloc.add(const SearchStudent('johnny'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(studentBloc.state.filteredStudents.length, 1);
      expect(studentBloc.state.filteredStudents.first.name, 'Johnny');
    });

    test('add multiple then delete one', () async {
      const student1 = StudentModel(id: '1', name: 'John', email: 'john@example.com', phoneNumber: '111');
      const student2 = StudentModel(id: '2', name: 'Jane', email: 'jane@example.com', phoneNumber: '222');
      const student3 = StudentModel(id: '3', name: 'Bob', email: 'bob@example.com', phoneNumber: '333');

      studentBloc.add(const AddStudent(student1));
      studentBloc.add(const AddStudent(student2));
      studentBloc.add(const AddStudent(student3));
      await studentBloc.stream.skip(2).first;

      studentBloc.add(const DeleteStudent('2'));
      await studentBloc.stream.first;

      expect(studentBloc.state.students.length, 2);
      expect(studentBloc.state.students[0].id, '1');
      expect(studentBloc.state.students[1].id, '3');
    });
  });
}
