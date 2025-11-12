import 'package:bloc_test/bloc/student/student_bloc.dart';
import 'package:bloc_test/bloc/student/student_states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/student/student_events.dart';
import '../../models/student_model.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    print("====>>>Test");
    print("====>>Test2");
    print("===>>>Test3");
    print("===>>>Test4");
    print("===>>>Test5");
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Add student"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          spacing: 20,
          children: [
            TextField(
              controller: nameController,
              onTapOutside:(_)=> FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.amber)
                ),
                hintText: "student Name",
              ),
            ),
            TextField(
              controller: emailController,
              onTapOutside:(_)=> FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber)
                ),
                hintText: "student Email",
              ),
            ),
            TextField(
              controller: phoneController,
              onTapOutside:(_)=> FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber)
                ),
                hintText: "student Phone Number",
              ),
            ),
            Text("Hello Test There"),
            ElevatedButton(onPressed: (){
              context.read<StudentBloc>().add(AddStudent(StudentModel(
                  id: context.read<StudentBloc>().state.students.length.toString(),
                name: nameController.text,
                email: emailController.text,
                phoneNumber: phoneController.text
              )));
              Navigator.pop(context);
            }, child: Text("Add Student")),
          ],
        ))
    );
  }



  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  void addRecord(){
    print("add setState");
    setState(() {

    });
  }

}
