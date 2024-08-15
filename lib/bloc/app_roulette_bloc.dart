// lib/bloc/app_roulette_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
import 'dart:math';

class RouletteBloc extends Bloc<RouletteEvent, RouletteState> {
  RouletteBloc() : super(RouletteInitial()) {
    on<StartRoulette>(_onStartRoulette);
    on<SetRouletteResult>(_onSetRouletteResult);
  }

  // Handle StartRoulette event
  Future<void> _onStartRoulette(
      StartRoulette event, Emitter<RouletteState> emit) async {
    emit(RouletteSpinning());

    // Simulate spinning
    await Future.delayed(const Duration(seconds: 2));

    // The result is set later using SetRouletteResult event
  }

  // Handle SetRouletteResult event
  void _onSetRouletteResult(
      SetRouletteResult event, Emitter<RouletteState> emit) {
    emit(RouletteStopped(event.result));
  }

  // Determine prize index based on roulette position
  String determinePrize(int index) {
    switch (index) {
      case 0:
        return 'You won Prize 1!';
      case 1:
        return 'You won Prize 2!';
      case 2:
        return 'You won Prize 3!';
      case 3:
        return 'You won Prize 4!';
      default:
        return 'Sorry, no prize this time!';
    }
  }
}
