import 'package:bloc/bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
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

  Future<void> _onLoadPrizes(
      LoadPrizes event, Emitter<RouletteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final prizes = prefs.getStringList('prizes') ?? [];
    emit(PrizesLoaded(prizes));
  }

  Future<void> _onAddPrize(AddPrize event, Emitter<RouletteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final prizes = prefs.getStringList('prizes') ?? [];
    prizes.add(event.prize);
    await prefs.setStringList('prizes', prizes);
    emit(PrizesLoaded(prizes));
  }

  Future<void> _onEditPrize(EditPrize event, Emitter<RouletteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final prizes = prefs.getStringList('prizes') ?? [];
    if (event.newPrize.isNotEmpty) {
      prizes[event.index] = event.newPrize;
      await prefs.setStringList('prizes', prizes);
      emit(PrizesLoaded(prizes));
    } else {
      emit(PrizesLoaded(prizes));
    }
  }

  Future<void> _onDeletePrize(
      DeletePrize event, Emitter<RouletteState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final prizes = prefs.getStringList('prizes') ?? [];
    prizes.removeAt(event.index);
    await prefs.setStringList('prizes', prizes);
    emit(PrizesLoaded(prizes));
  }

  Future<void> _onStartRoulette(
      StartRoulette event, Emitter<RouletteState> emit) async {
    emit(RouletteSpinning());
    await Future.delayed(const Duration(seconds: 2));
  }

  void _onSetRouletteResult(
      SetRouletteResult event, Emitter<RouletteState> emit) {
    emit(RouletteStopped(event.result));
  }

  String determinePrize(int index, List<String> prizes) {
    if (index < prizes.length) {
      return 'You won ${prizes[index]}!';
    } else {
      return 'Sorry, no prize this time!';
    }
  }
}
