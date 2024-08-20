import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/pages/roulette_page.dart';
import 'package:app_roulette/pages/add_prize.dart';
import 'package:app_roulette/pages/edit_prize.dart';
import 'package:app_roulette/models/prize.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouletteBloc(),
      child: MaterialApp(
        title: 'Roulette App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: const RoulettePage(),
        routes: {
          '/addPrize': (context) => const AddPrizePage(),
          '/editPrizes': (context) => const EditPrizesPage(prizes: []), // Pass an empty list or load initial prizes
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/editPrize') {
            final args = settings.arguments as Map<String, dynamic>?;

            if (args != null) {
              final Prize currentPrize = args['currentPrize'] as Prize;
              final int index = args['index'] as int;

              return MaterialPageRoute(
                builder: (context) => AddPrizePage(
                  prize: currentPrize,
                  index: index,
                ),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
