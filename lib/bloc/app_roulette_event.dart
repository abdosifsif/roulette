import 'package:equatable/equatable.dart';

abstract class RouletteEvent extends Equatable {
  const RouletteEvent();

  @override
  List<Object> get props => [];
}

class LoadPrizes extends RouletteEvent {}

class AddPrize extends RouletteEvent {
  final String prize;

  const AddPrize(this.prize);

  @override
  List<Object> get props => [prize];
}

class EditPrize extends RouletteEvent {
  final int index;
  final String newPrize;

  const EditPrize(this.index, this.newPrize);

  @override
  List<Object> get props => [index, newPrize];
}

class DeletePrize extends RouletteEvent {
  final int index;

  const DeletePrize(this.index);

  @override
  List<Object> get props => [index];
}

class StartRoulette extends RouletteEvent {}

class SetRouletteResult extends RouletteEvent {
  final String result;

  const SetRouletteResult(this.result);

  @override
  List<Object> get props => [result];
}
