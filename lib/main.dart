import 'package:bloc_test/bloc/counter/counter_bloc.dart';
import 'package:bloc_test/bloc/student/student_bloc.dart';
import 'package:bloc_test/ui/selectable/selectable_text_screen.dart';
import 'package:bloc_test/ui/students/students_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CounterBloc>(
          create: (context) => CounterBloc(),
        ),
        BlocProvider<StudentBloc>(
          create: (context) => StudentBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const StudentsScreen(),
      ),
    );
  }
}


