import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';

class RouletteBloc extends Bloc<RouletteEvent, RouletteState> {
  RouletteBloc() : super(RouletteInitial()) {
    // Registering the handler for the StartRoulette event
    on<StartRoulette>(_onStartRoulette);
  }

  // Event handler for StartRoulette
  Future<void> _onStartRoulette(
      StartRoulette event, Emitter<RouletteState> emit) async {
    emit(RouletteSpinning());
    // Simulate spinning
    await Future.delayed(const Duration(seconds: 2));
    emit(RouletteStopped("Congratulations! You won!"));
  }
}
