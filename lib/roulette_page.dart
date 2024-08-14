import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roulette/roulette.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
import 'dart:math';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> with SingleTickerProviderStateMixin {
  late RouletteController _rouletteController;

  @override
  void initState() {
    super.initState();

    // Create roulette units
    final units = [
      RouletteUnit.text('Prize 1', color: Colors.red),
      RouletteUnit.text('Prize 2', color: Colors.green),
      RouletteUnit.text('Prize 3', color: Colors.blue),
      RouletteUnit.text('Prize 4', color: Colors.yellow),
    ];

    // Initialize the roulette controller
    _rouletteController = RouletteController(
      group: RouletteGroup(units),
      vsync: this, // TickerProvider, usually from SingleTickerProviderStateMixin
    );
  }

  @override
  void dispose() {
    _rouletteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette App'),
      ),
      body: BlocConsumer<RouletteBloc, RouletteState>(
        listener: (context, state) {
          if (state is RouletteStopped) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Result: ${state.result}')),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Roulette widget
                Roulette(
                  controller: _rouletteController,
                  style: const RouletteStyle(
                    dividerThickness: 4.0,
                    textLayoutBias: .8,
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                if (state is RouletteSpinning)
                  const CircularProgressIndicator()
                else
                  const Text('Press the button to spin'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Randomly select a unit to spin to
                    final random = Random();
                    final int selectedUnit = random.nextInt(_rouletteController.group.units.length);
                    final double offset = random.nextDouble();

                    // Dispatch the StartRoulette event
                    context.read<RouletteBloc>().add(StartRoulette());

                    // Spin the roulette
                    await _rouletteController.rollTo(selectedUnit, offset: offset);

                    // Stop the roulette with the selected result
                    context.read<RouletteBloc>().add(StopRoulette('Prize ${selectedUnit + 1}'));
                  },
                  child: const Text('Spin Roulette'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
