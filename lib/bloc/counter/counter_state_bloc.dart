import 'package:equatable/equatable.dart';

class CounterState extends Equatable{
  final int counter;
  final bool isIsolateRunning;
  final bool isIsolatePaused;

  const CounterState({
    this.counter=0,
    this.isIsolateRunning = false,
    this.isIsolatePaused = false,
  });

  CounterState copyWith({
    int? counter,
    bool? isIsolateRunning,
    bool? isIsolatePaused,
  }){
    return CounterState(
      counter: counter ?? this.counter,
      isIsolateRunning: isIsolateRunning ?? this.isIsolateRunning,
      isIsolatePaused: isIsolatePaused ?? this.isIsolatePaused,
    );
  }


  @override
  List<Object?> get props => [counter, isIsolateRunning, isIsolatePaused];

}