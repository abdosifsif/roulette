// app_roulette_event.dart
import 'package:equatable/equatable.dart';
import 'package:app_roulette/models/prize.dart';

abstract class RouletteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPrizes extends RouletteEvent {}

class AddPrize extends RouletteEvent {
  final Prize prize;

  AddPrize(this.prize);

  @override
  List<Object?> get props => [prize];
}

class EditPrize extends RouletteEvent {
  final int index;
  final Prize newPrize;

  EditPrize(this.index, this.newPrize);

  @override
  List<Object?> get props => [index, newPrize];
}

class DeletePrize extends RouletteEvent {
  final int index;

  DeletePrize(this.index);

  @override
  List<Object?> get props => [index];
}

class StartRoulette extends RouletteEvent {}

class SetRouletteResult extends RouletteEvent {
  final Prize result;

  SetRouletteResult({required this.result});

  @override
  List<Object?> get props => [result];
}
