// lib/roulette_page.dart
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

class _RoulettePageState extends State<RoulettePage>
    with SingleTickerProviderStateMixin {
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
      vsync: this,
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
            // Show SnackBar with result when roulette stops
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.result)),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Roulette with custom arrow pointer
                SizedBox(
                  height: 300, // Adjust height as needed
                  width: 300, // Adjust width as needed
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Roulette widget
                      Roulette(
                        controller: _rouletteController,
                        style: const RouletteStyle(
                          dividerThickness: 4.0,
                          textLayoutBias: .8,
                          textStyle: TextStyle(fontSize: 20),
                        ),
                      ),
                      // Arrow indicator using a custom ClipPath
                      Positioned(
                        top: -10, // Adjust to position the arrow correctly
                        child: CustomPaint(
                          size: const Size(30, 30), // Adjust the size of the arrow
                          painter: _ArrowPainter(color: Colors.orange), // Change color as needed
                        ),
                      ),
                    ],
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

                    // Dispatch the SetRouletteResult event with the determined prize
                    final prizeMessage = context.read<RouletteBloc>().determinePrize(selectedUnit);
                    context.read<RouletteBloc>().add(SetRouletteResult(prizeMessage));
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

// Custom painter class for the downward pointing arrow indicator
class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Define the path for a downward pointing triangle
    path.moveTo(size.width / 2, size.height); // Starting at bottom center
    path.lineTo(size.width, 0); // Top right corner
    path.lineTo(0, 0); // Top left corner
    path.close(); // Close the path to form a triangle

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
