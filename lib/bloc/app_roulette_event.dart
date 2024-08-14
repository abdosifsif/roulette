// app_roulette_event.dart
import 'package:equatable/equatable.dart';

abstract class RouletteEvent extends Equatable {
  const RouletteEvent();
}

class StartRoulette extends RouletteEvent {
  @override
  List<Object?> get props => [];
}

// Add this class
class StopRoulette extends RouletteEvent {
  final String result;

  const StopRoulette(this.result);

  @override
  List<Object?> get props => [result];
}
