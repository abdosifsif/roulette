import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
import 'package:app_roulette/models/prize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouletteBloc extends Bloc<RouletteEvent, RouletteState> {
  RouletteBloc() : super(RouletteInitial()) {
    on<LoadPrizes>(_onLoadPrizes);
    on<AddPrize>(_onAddPrize);
    on<EditPrize>(_onEditPrize);
    on<DeletePrize>(_onDeletePrize);
    on<StartRoulette>(_onStartRoulette);
    on<SetRouletteResult>(_onSetRouletteResult);
  }

  Future<void> _onLoadPrizes(LoadPrizes event, Emitter<RouletteState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? prizeStrings = prefs.getStringList('prizes');
      final List<Prize> prizes = prizeStrings != null
          ? prizeStrings.map((prizeString) => Prize.fromString(prizeString)).toList()
          : [];
      emit(PrizesLoaded(prizes));
    } catch (e) {
      emit(RouletteError('Failed to load prizes'));
    }
  }

  Future<void> _onAddPrize(AddPrize event, Emitter<RouletteState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? prizeStrings = prefs.getStringList('prizes');
      final List<Prize> prizes = prizeStrings != null
          ? prizeStrings.map((prizeString) => Prize.fromString(prizeString)).toList()
          : [];

      prizes.add(event.prize);
      await prefs.setStringList('prizes', prizes.map((prize) => prize.toString()).toList());
      emit(PrizesLoaded(prizes));
    } catch (e) {
      emit(RouletteError('Failed to add prize'));
    }
  }

  Future<void> _onEditPrize(EditPrize event, Emitter<RouletteState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? prizeStrings = prefs.getStringList('prizes');
      final List<Prize> prizes = prizeStrings != null
          ? prizeStrings.map((prizeString) => Prize.fromString(prizeString)).toList()
          : [];

      if (event.index >= 0 && event.index < prizes.length) {
        prizes[event.index] = event.newPrize;
        await prefs.setStringList('prizes', prizes.map((prize) => prize.toString()).toList());
        emit(PrizesLoaded(prizes));
      } else {
        emit(RouletteError('Invalid prize index'));
      }
    } catch (e) {
      emit(RouletteError('Failed to edit prize'));
    }
  }

  Future<void> _onDeletePrize(DeletePrize event, Emitter<RouletteState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? prizeStrings = prefs.getStringList('prizes');
      final List<Prize> prizes = prizeStrings != null
          ? prizeStrings.map((prizeString) => Prize.fromString(prizeString)).toList()
          : [];

      if (event.index >= 0 && event.index < prizes.length) {
        prizes.removeAt(event.index);
        await prefs.setStringList('prizes', prizes.map((prize) => prize.toString()).toList());
        emit(PrizesLoaded(prizes));
      } else {
        emit(RouletteError('Invalid prize index'));
      }
    } catch (e) {
      emit(RouletteError('Failed to delete prize'));
    }
  }

  Future<void> _onStartRoulette(StartRoulette event, Emitter<RouletteState> emit) async {
    final prizesState = state;
    if (prizesState is PrizesLoaded && prizesState.prizes.isNotEmpty) {
      try {
        final prize = determinePrize(prizesState.prizes);
        emit(RouletteSpinning(prize: prize));
      } catch (e) {
        emit(RouletteError('Failed to start roulette'));
      }
    } else {
      emit(RouletteError('No prizes available'));
    }
  }

  Prize determinePrize(List<Prize> prizes) {
    final random = Random();
    final totalWeight = prizes.fold(0.0, (sum, prize) => sum + prize.percentage);

    if (totalWeight <= 0) {
      throw Exception('Total percentage must be greater than 0');
    }

    double randomValue = random.nextDouble() * totalWeight;
    for (var prize in prizes) {
      randomValue -= prize.percentage;
      if (randomValue <= 0) {
        return prize;
      }
    }

    return prizes.last;
  }

  Future<void> _onSetRouletteResult(SetRouletteResult event, Emitter<RouletteState> emit) async {
    emit(RouletteStopped(prize: event.result));
  }
}
