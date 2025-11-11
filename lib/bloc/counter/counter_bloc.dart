import 'package:bloc/bloc.dart';
import 'counter_event_bloc.dart';
import 'counter_state_bloc.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState>{

  CounterBloc(): super(CounterState(counter: 3)){
    on<increament>(_increament);
    on<decreament>(_decreament);
    on<reset>(_reset);
  }

  void _increament(CounterEvent event, Emitter<CounterState> emit){
      emit(state.copyWith(counter: state.counter + 1));
  }

  void _decreament(CounterEvent event, Emitter<CounterState> emit){
    emit(state.copyWith(counter: state.counter - 1));
  }

  void _reset(CounterEvent event, Emitter<CounterState> emit){
    emit(state.copyWith(counter: 0));
  }

}