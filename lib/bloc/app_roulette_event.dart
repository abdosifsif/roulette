import 'package:app_roulette/models/prize.dart';

abstract class RouletteEvent {}

class LoadPrizes extends RouletteEvent {}

class AddPrize extends RouletteEvent {
  final Prize prize;

  AddPrize({required this.prize});
}

class EditPrize extends RouletteEvent {
  final int index;
  final Prize newPrize;

  EditPrize({required this.index, required this.newPrize});
}

class DeletePrize extends RouletteEvent {
  final int index;

  DeletePrize({required this.index});
}

class StartRoulette extends RouletteEvent {}

class SetRouletteResult extends RouletteEvent {
  final Prize result;

  SetRouletteResult({required this.result});
}