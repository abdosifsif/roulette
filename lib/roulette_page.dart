import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roulette/roulette.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
import 'dart:math';

class RoulettePage extends StatefulWidget {
  const RoulettePage({Key? key}) : super(key: key);

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with SingleTickerProviderStateMixin {
  RouletteController? _rouletteController;

  @override
  void initState() {
    super.initState();
    context.read<RouletteBloc>().add(LoadPrizes());
  }

  @override
  void dispose() {
    _rouletteController?.dispose();
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
              SnackBar(content: Text(state.result)),
            );
          }
        },
        builder: (context, state) {
          if (state is PrizesLoaded) {
            _rouletteController = RouletteController(
              group: RouletteGroup(state.prizes
                  .map((prize) => RouletteUnit.text(prize))
                  .toList()),
              vsync: this,
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_rouletteController != null)
                        Roulette(
                          controller: _rouletteController!,
                          style: const RouletteStyle(
                            dividerThickness: 4.0,
                            textLayoutBias: .8,
                            textStyle: TextStyle(fontSize: 20),
                          ),
                        ),
                      Positioned(
                        top: -10,
                        child: CustomPaint(
                          size: const Size(30, 30),
                          painter: _ArrowPainter(color: Colors.orange),
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
                    final random = Random();
                    final int selectedUnit = random.nextInt(
                        _rouletteController!.group.units.length);
                    final double offset = random.nextDouble();

                    context.read<RouletteBloc>().add(StartRoulette());

                    await _rouletteController!.rollTo(selectedUnit,
                        offset: offset);

                    final prizeMessage = context
                        .read<RouletteBloc>()
                        .determinePrize(selectedUnit, (state as PrizesLoaded).prizes);
                    context.read<RouletteBloc>().add(SetRouletteResult(prizeMessage));
                  },
                  child: const Text('Spin Roulette'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPrize');
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Prize',
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
