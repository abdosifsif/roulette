import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';

class AddPrizePage extends StatelessWidget {
  final String? prize;
  final int? index;

  const AddPrizePage({super.key, this.prize, this.index});

  @override
  Widget build(BuildContext context) {
    final TextEditingController prizeController =
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
              controller: prizeController,
              decoration: const InputDecoration(labelText: 'Prize'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newPrize = prizeController.text;
                if (newPrize.isNotEmpty) {
                  if (index != null) {
                    
                    context.read<RouletteBloc>().add(EditPrize(index!, newPrize));
                  } else {
                    
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
