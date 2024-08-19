import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';

class AddPrizePage extends StatelessWidget {
  final String? prize;
  final int? index;

  const AddPrizePage({Key? key, this.prize, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _prizeController =
        TextEditingController(text: prize);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prize'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _prizeController,
              decoration: const InputDecoration(labelText: 'Prize'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newPrize = _prizeController.text;
                if (newPrize.isNotEmpty) {
                  if (index != null) {
                    // Edit existing prize
                    context.read<RouletteBloc>().add(EditPrize(index!, newPrize));
                  } else {
                    // Add new prize
                    context.read<RouletteBloc>().add(AddPrize(newPrize));
                  }
                  Navigator.pop(context, true); // Notify success
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
