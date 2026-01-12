import 'package:bloc_test/bloc/counter/counter_event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:isolate';
import 'dart:async';

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
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ()=> context.read<CounterBloc>().add(automaticIsolate()), 
                child: Text("Automatic Isolate")
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: ()=> context.read<CounterBloc>().add(manualIsolate()), 
                child: Text("Manual Isolate")
              ),
            ],
          ),
          SizedBox(height: 20),
          BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              return Column(
                children: [
                  Text(
                    state.isIsolateRunning 
                      ? (state.isIsolatePaused ? "Isolate: Paused" : "Isolate: Running")
                      : "Isolate: Stopped",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.isIsolateRunning 
                        ? (state.isIsolatePaused ? Colors.orange : Colors.green)
                        : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.read<CounterBloc>().add(playIsolate()),
                        child: Icon(state.isIsolatePaused ? Icons.play_arrow : Icons.play_circle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: state.isIsolateRunning && !state.isIsolatePaused
                          ? () => context.read<CounterBloc>().add(pauseIsolate())
                          : null,
                        child: Icon(Icons.pause_circle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          )

        ],
      ),
    );
  }
}
