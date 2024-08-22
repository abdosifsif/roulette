// add_prize.dart
import 'package:flutter/material.dart';
import 'package:app_roulette/models/prize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';

class AddPrizePage extends StatefulWidget {
  final Prize? prize;
  final int? index;

  const AddPrizePage({Key? key, this.prize, this.index}) : super(key: key);

  @override
  _AddPrizePageState createState() => _AddPrizePageState();
}

class _AddPrizePageState extends State<AddPrizePage> {
  late TextEditingController _nameController;
  late TextEditingController _percentageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prize?.name ?? '');
    _percentageController =
        TextEditingController(text: widget.prize?.percentage.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _savePrize() async {
    final newPrize = Prize(
      name: _nameController.text,
      percentage: double.tryParse(_percentageController.text) ?? 0,
    );

    // Retrieve the current list of prizes from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final prizeStrings = prefs.getStringList('prizes') ?? [];

    // If editing an existing prize, replace it; otherwise, add the new prize
    if (widget.index != null) {
      prizeStrings[widget.index!] = newPrize.toString();
    } else {
      prizeStrings.add(newPrize.toString());
    }

    // Save the updated prize list back to SharedPreferences
    await prefs.setStringList('prizes', prizeStrings);

    // Trigger an event in the BLoC to reload the prizes
    context.read<RouletteBloc>().add(LoadPrizes());

    Navigator.pop(context, true); // Return to the EditPrizesPage with result
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null ? 'Add Prize' : 'Edit Prize'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Prize',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _percentageController,
              decoration: const InputDecoration(
                labelText: 'Percentage',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePrize,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
