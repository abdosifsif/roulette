import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
import 'package:roulette/roulette.dart';
import 'dart:math';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> with TickerProviderStateMixin {
  RouletteController? _rouletteController;
  List<String> _prizes = [];

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

  void _initializeRouletteController(List<String> prizes) {
    final colors = _generateColors(prizes.length);
    _rouletteController?.dispose();
    _rouletteController = RouletteController(
      group: RouletteGroup(
        prizes.asMap().entries.map((entry) {
          final index = entry.key;
          final prize = entry.value;
          return RouletteUnit.text(
            prize,
            color: colors[index],
          );
        }).toList(),
      ),
      vsync: this,
    );
    setState(() {
      _prizes = prizes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (_prizes.isNotEmpty) {
                final result = await Navigator.pushNamed(
                  context,
                  '/editPrize',
                  arguments: {
                    'index': 0, // Pass the correct index here
                    'currentPrize': _prizes[0], // Pass the current prize
                  },
                );
                if (result == true) {
                  context.read<RouletteBloc>().add(LoadPrizes());
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No prizes to edit')),
                );
              }
            },
            tooltip: 'Edit Prize',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/addPrize');
              if (result == true) {
                context.read<RouletteBloc>().add(LoadPrizes());
              }
            },
            tooltip: 'Add Prize',
          ),
        ],
      ),
      body: BlocConsumer<RouletteBloc, RouletteState>(
        listener: (context, state) {
          if (state is PrizesLoaded) {
            _initializeRouletteController(state.prizes);
          }
          if (state is RouletteStopped) {
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
                        )
                      else
                        const Text('Loading Roulette...'),
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
                    if (_rouletteController?.group.units.isNotEmpty ?? false) {
                      final int selectedUnit = random.nextInt(
                        _rouletteController!.group.units.length,
                      );
                      final double offset = random.nextDouble();

                      context.read<RouletteBloc>().add(StartRoulette());

                      await _rouletteController!.rollTo(
                        selectedUnit,
                        offset: offset,
                      );

                      final prizeMessage = context
                          .read<RouletteBloc>()
                          .determinePrize(selectedUnit, _prizes);

                      context
                          .read<RouletteBloc>()
                          .add(SetRouletteResult(prizeMessage));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prizes are not loaded yet!')),
                      );
                    }
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

  List<Color> _generateColors(int count) {
    final List<Color> colors = [];
    final Random random = Random();
    for (int i = 0; i < count; i++) {
      colors.add(Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ));
    }
    return colors;
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
