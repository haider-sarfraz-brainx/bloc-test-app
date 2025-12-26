import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/student/student_bloc.dart';
import '../../bloc/student/student_events.dart';
import '../../bloc/student/student_states.dart';
import '../../../domain/entities/student_entity.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final Completer<void> completer = Completer<void>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amber,
            title: const Text("Add student"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              spacing: 20,
              children: [
                TextField(
                  controller: nameController,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    hintText: "student Name",
                  ),
                ),
                TextField(
                  controller: emailController,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    hintText: "student Email",
                  ),
                ),
                TextField(
                  controller: phoneController,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    hintText: "student Phone Number",
                  ),
                ),
                ElevatedButton(
                  onPressed: addStudent,
                  child: const Text("Add Student"),
                ),
              ],
            ),
          ),
        ),
        BlocSelector<StudentBloc, StudentState, bool>(
          selector: (state) => state.loading,
          builder: (context, isLoading) {
            return isLoading
                ? Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    ),
                  )
                : const SizedBox();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Future<void> addStudent() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final studentBloc = context.read<StudentBloc>();
    final studentCount = studentBloc.state.students.length;

    final student = StudentEntity(
      id: studentCount.toString(),
      name: nameController.text,
      email: emailController.text,
      phoneNumber: phoneController.text,
    );

    studentBloc.add(AddStudentEvent(student));

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

