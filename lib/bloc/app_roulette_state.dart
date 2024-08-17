import 'package:equatable/equatable.dart';

abstract class RouletteState extends Equatable {
  const RouletteState();

  @override
  List<Object> get props => [];
}

class RouletteInitial extends RouletteState {}

class RouletteSpinning extends RouletteState {}

class RouletteStopped extends RouletteState {
  final String result;

  const RouletteStopped(this.result);

  @override
  List<Object> get props => [result];
}

// State representing when prizes have been updated
class PrizesLoaded extends RouletteState {
  final List<String> prizes;

  const PrizesLoaded(this.prizes);

  @override
  List<Object> get props => [prizes];
}
