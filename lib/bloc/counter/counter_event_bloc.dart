import 'package:equatable/equatable.dart';

abstract class CounterEvent extends Equatable{
  const CounterEvent();
  @override
  List<Object?> get props => [];
}

class increament extends CounterEvent{}
class decreament extends CounterEvent{}
class reset extends CounterEvent{}
