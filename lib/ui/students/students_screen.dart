import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/student/student_bloc.dart';
import '../../bloc/student/student_events.dart';
import '../../bloc/student/student_states.dart';
import '../../flavour/flavour_config.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Students - ${FlavourConfig.instance.name} - ${FlavourConfig.instance.baseUrl}", style: TextStyle(fontSize: 12),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudentScreen()));
          }, icon: Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text("Hello Test There"),
            Text('Hello Test There'),
            Text("Hello Test There"),
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
            BlocSelector<StudentBloc, StudentState, List<StudentModel>>(
              selector: (state) => state.filteredStudents,
              builder: (context, students) {

                return SizedBox(height: 10,);
              }
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
    );
  }
  void addRecord(){
    print("Testing to add setState");
    setState(() {});
  }
}
