import 'dart:math';
import 'package:app_roulette/pages/edit_prize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/bloc/app_roulette_state.dart';
import 'package:app_roulette/models/prize.dart';
import 'package:roulette/roulette.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({Key? key}) : super(key: key);

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> with TickerProviderStateMixin {
  RouletteController? _rouletteController;
  List<Prize> _prizes = [];

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

  void _initializeRouletteController(List<Prize> prizes) {
    final prizeNames = prizes.map((prize) => prize.name).toList();
    final colors = _generateColors(prizeNames.length);
    _rouletteController?.dispose();
    _rouletteController = RouletteController(
      group: RouletteGroup(
        prizeNames.asMap().entries.map((entry) {
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

  void _showPrizeDialog(Prize prize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prize Result'),
          content: Text('Congratulations! You won ${prize.name}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPrizesPage(prizes: _prizes),
                  ),
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
            _showPrizeDialog(state.prize);
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

                      final Prize selectedPrize = _prizes[selectedUnit];
                      context.read<RouletteBloc>().add(SetRouletteResult(result: selectedPrize));
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
