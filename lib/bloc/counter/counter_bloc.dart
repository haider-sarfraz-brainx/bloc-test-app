import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:isolate';
import 'dart:async';
import 'counter_event_bloc.dart';
import 'counter_state_bloc.dart';

int heavyCalculation(int value) {
  var result = 0;
  for (var i = 0; i < 10000; i++) {
    result += value;
    print("result:  $result");
  }
  return result;
}

void isolateEntryPoint(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  
  receivePort.listen((message) {
    if (message is int) {
      final result = heavyCalculation(message);
      sendPort.send(result);
    }
  });
}

void controllableIsolateEntryPoint(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  
  bool isPaused = false;
  bool isRunning = false;
  int currentValue = 0;
  int result = 0;
  
  receivePort.listen((message) {
    if (message == 'start') {
      isRunning = true;
      isPaused = false;
      sendPort.send('started');
      
      Future.microtask(() async {
        for (var i = 0; i < 10000; i++) {
          while (isPaused && isRunning) {
            await Future.delayed(Duration(milliseconds: 100));
          }
          
          if (!isRunning) break;
          
          result += currentValue;
          print("Controllable Isolate: result: $result");
          
          if (i % 1000 == 0) {
            sendPort.send({'progress': i, 'result': result});
          }
        }
        
        if (isRunning) {
          sendPort.send({'completed': result});
          isRunning = false;
        }
      });
    } else if (message == 'pause') {
      isPaused = true;
      sendPort.send('paused');
    } else if (message == 'resume') {
      isPaused = false;
      sendPort.send('resumed');
    } else if (message is int) {
      currentValue = message;
    } else if (message == 'stop') {
      isRunning = false;
      isPaused = false;
      sendPort.send('stopped');
    }
  });
}

class CounterBloc extends Bloc<CounterEvent, CounterState>{
  Isolate? _controllableIsolate;
  SendPort? _isolateSendPort;
  ReceivePort? _isolateReceivePort;
  StreamSubscription? _isolateSubscription;

  CounterBloc(): super(CounterState(counter: 3)){
    on<increament>(_increament);
    on<decreament>(_decreament);
    on<reset>(_reset);
    on<automaticIsolate>(_automaticIsolate);
    on<manualIsolate>(_manualIsolate);
    on<playIsolate>(_playIsolate);
    on<pauseIsolate>(_pauseIsolate);
    on<_UpdateIsolateStatusEvent>(_updateIsolateStatus);
    on<_IncrementCounterEvent>(_incrementFromIsolate);
  }

  @override
  Future<void> close() {
    _cleanupIsolate();
    return super.close();
  }

  void _cleanupIsolate() {
    _isolateSubscription?.cancel();
    _isolateSubscription = null;
    if (_controllableIsolate != null) {
      _isolateSendPort?.send('stop');
      _controllableIsolate?.kill();
      _controllableIsolate = null;
      _isolateSendPort = null;
      _isolateReceivePort?.close();
      _isolateReceivePort = null;
    }
  }

  Future<void> _increament(CounterEvent event, Emitter<CounterState> emit) async {
     final result = await compute(heavyCalculation, 5);
      print("Completed:  $result");
      emit(state.copyWith(counter: state.counter + 1));
  }

  void _decreament(CounterEvent event, Emitter<CounterState> emit){
    emit(state.copyWith(counter: state.counter - 1));
  }

  void _reset(CounterEvent event, Emitter<CounterState> emit){
    emit(state.copyWith(counter: 0));
  }

  Future<void> _automaticIsolate(CounterEvent event, Emitter<CounterState> emit) async {
    print("Automatic Isolate: Starting...");
    final result = await compute(heavyCalculation, 5);
    print("Automatic Isolate: Completed - $result");
    emit(state.copyWith(counter: state.counter + 1));
  }

  Future<void> _manualIsolate(CounterEvent event, Emitter<CounterState> emit) async {
    print("Manual Isolate: Starting...");
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(isolateEntryPoint, receivePort.sendPort);
    
    final completer = Completer<int>();
    receivePort.listen((message) {
      print("Manual Isolate: Received message - $message");
      if (message is SendPort) {
        message.send(5);
      } else if (message is int) {
        completer.complete(message);
        receivePort.close();
        isolate.kill();
      }
    });
    
    final result = await completer.future;
    print("Manual Isolate: Completed - $result");
    emit(state.copyWith(counter: state.counter + 1));
  }

  Future<void> _playIsolate(CounterEvent event, Emitter<CounterState> emit) async {
    if (state.isIsolateRunning && !state.isIsolatePaused) {
      print("Isolate is already running");
      return;
    }

    if (state.isIsolatePaused) {
      _isolateSendPort?.send('resume');
      emit(state.copyWith(isIsolatePaused: false));
      print("Isolate resumed");
      return;
    }

    print("Play Isolate: Starting...");
    _cleanupIsolate();
    
    _isolateReceivePort = ReceivePort();
    _controllableIsolate = await Isolate.spawn(
      controllableIsolateEntryPoint,
      _isolateReceivePort!.sendPort,
    );

    _isolateSubscription = _isolateReceivePort!.listen((message) {
      print("Play Isolate: Received message - $message");
      
      if (message is SendPort) {
        _isolateSendPort = message;
        _isolateSendPort!.send(5);
        _isolateSendPort!.send('start');
        add(_UpdateIsolateStatusEvent(isRunning: true, isPaused: false));
      } else if (message == 'started') {
        add(_UpdateIsolateStatusEvent(isRunning: true, isPaused: false));
      } else if (message == 'paused') {
        add(_UpdateIsolateStatusEvent(isRunning: true, isPaused: true));
      } else if (message == 'resumed') {
        add(_UpdateIsolateStatusEvent(isRunning: true, isPaused: false));
      } else if (message == 'stopped') {
        add(_UpdateIsolateStatusEvent(isRunning: false, isPaused: false));
      } else if (message is Map) {
        if (message.containsKey('completed')) {
          final result = message['completed'] as int;
          print("Play Isolate: Completed - $result");
          add(_UpdateIsolateStatusEvent(isRunning: false, isPaused: false));
          add(_IncrementCounterEvent());
        } else if (message.containsKey('progress')) {
          print("Play Isolate: Progress - ${message['progress']}, Result - ${message['result']}");
        }
      }
    });

    emit(state.copyWith(isIsolateRunning: true, isIsolatePaused: false));
  }

  void _pauseIsolate(CounterEvent event, Emitter<CounterState> emit) {
    if (!state.isIsolateRunning || state.isIsolatePaused) {
      print("Isolate is not running or already paused");
      return;
    }

    _isolateSendPort?.send('pause');
    emit(state.copyWith(isIsolatePaused: true));
    print("Isolate paused");
  }

  void _updateIsolateStatus(_UpdateIsolateStatusEvent event, Emitter<CounterState> emit) {
    emit(state.copyWith(
      isIsolateRunning: event.isRunning,
      isIsolatePaused: event.isPaused,
    ));
  }

  void _incrementFromIsolate(_IncrementCounterEvent event, Emitter<CounterState> emit) {
    emit(state.copyWith(counter: state.counter + 1));
  }
}

class _UpdateIsolateStatusEvent extends CounterEvent {
  final bool isRunning;
  final bool isPaused;
  
  _UpdateIsolateStatusEvent({required this.isRunning, required this.isPaused});
  
  @override
  List<Object?> get props => [isRunning, isPaused];
}

class _IncrementCounterEvent extends CounterEvent {}