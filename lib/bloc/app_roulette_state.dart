// lib/bloc/app_roulette_state.dart
import 'package:app_roulette/models/prize.dart';

abstract class RouletteState {}

class RouletteInitial extends RouletteState {}

class PrizesLoaded extends RouletteState {
  final List<Prize> prizes;

  PrizesLoaded(this.prizes);
}

class RouletteSpinning extends RouletteState {
  final Prize prize;

  RouletteSpinning({required this.prize});
}

class RouletteStopped extends RouletteState {
  final Prize prize;

  RouletteStopped({required this.prize});
}

class RouletteError extends RouletteState {
  final String message;

  RouletteError(this.message);
}
