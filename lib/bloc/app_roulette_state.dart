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
