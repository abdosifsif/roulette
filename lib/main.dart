import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/roulette_page.dart';

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
      ),
    );
  }
}
