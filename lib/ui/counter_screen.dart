import 'package:bloc_test/bloc/counter/counter_event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/counter/counter_bloc.dart';
import '../bloc/counter/counter_state_bloc.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("Counter App"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlocBuilder<CounterBloc, CounterState>(
            builder: (context,state) {
              return Text(state.counter.toString(), style: TextStyle(fontSize: 50),);
            }
          ),
          Row(
            children: [
              ElevatedButton(onPressed: ()=> context.read<CounterBloc>().add(increament()), child: Text("Increment")),
              ElevatedButton(onPressed: ()=> context.read<CounterBloc>().add(decreament()), child: Text("Decrement")),
              ElevatedButton(onPressed: ()=> context.read<CounterBloc>().add(reset()), child: Text("Reset")),
            ],
          )

        ],
      ),
    );
  }
}
