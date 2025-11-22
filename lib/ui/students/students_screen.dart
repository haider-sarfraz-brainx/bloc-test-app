import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/student/student_bloc.dart';
import '../../bloc/student/student_events.dart';
import '../../bloc/student/student_states.dart';
import '../../models/student_model.dart';
import 'add_student_screen.dart';

class StudentsScreen extends StatefulWidget {
  const   StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state.statusMessage != null && state.statusMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.statusMessage!),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text("Students", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudentScreen()));
            }, icon: Icon(Icons.add))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 20,
            children: [
              TextField(
                controller: searchController,
                onTapOutside:(_)=> FocusScope.of(context).unfocus(),
                onChanged: (String value)=> context.read<StudentBloc>().add(SearchStudent(value)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  hintText: "Search Students Here...",
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              Expanded(
                child:BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    List<StudentModel> students = state.filteredStudents;
                    return students.isNotEmpty? ListView.separated(itemBuilder: (context, index){
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber.shade200,
                            child: Center(child: Icon(Icons.person),),
                          ),
                          title: Text( students[index].name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(students[index].email),
                              Text(students[index].phoneNumber)
                            ],
                          ),
                          trailing: GestureDetector(
                              onTap: ()=> context.read<StudentBloc>().add(DeleteStudent(students[index].id)),
                              child: Icon(Icons.delete, color: Colors.red,)),
                        ),
                      );
                    }, separatorBuilder: (context, index) => SizedBox(height: 10,),
                        itemCount: students.length): Center(child: Text("No Record Found"),);
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
