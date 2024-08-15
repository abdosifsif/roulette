// lib/bloc/app_roulette_event.dart
import 'package:equatable/equatable.dart';

abstract class RouletteEvent extends Equatable {
  const RouletteEvent();

  @override
  List<Object?> get props => [];
}

class StartRoulette extends RouletteEvent {
  @override
  List<Object?> get props => [];
}

// Add this class
class SetRouletteResult extends RouletteEvent {
  final String result;

  const SetRouletteResult(this.result);

  @override
  List<Object?> get props => [result];
}
