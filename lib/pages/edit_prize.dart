// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, use_super_parameters

import 'package:app_roulette/models/prize.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:app_roulette/pages/add_prize.dart';

class EditPrizesPage extends StatefulWidget {
  final List<Prize> prizes;

  const EditPrizesPage({Key? key, required this.prizes}) : super(key: key);

  @override
  _EditPrizesPageState createState() => _EditPrizesPageState();
}

class _EditPrizesPageState extends State<EditPrizesPage> {
  late List<Prize> _prizes;

  @override
  void initState() {
    super.initState();
    _prizes = widget.prizes;
  }

  Future<void> _loadPrizes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _prizes = prefs.getStringList('prizes')?.map((e) => Prize.fromString(e)).toList() ?? [];
    });
  }

  Future<void> _deletePrize(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this prize?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _prizes.removeAt(index);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final updatedPrizeStrings = _prizes.map((prize) => prize.toString()).toList();
      await prefs.setStringList('prizes', updatedPrizeStrings);

      context.read<RouletteBloc>().add(LoadPrizes());
      Navigator.pop(context, true); // Navigate back to the previous screen
    }
  }

  Future<void> _editPrize(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPrizePage(
          prize: _prizes[index],
          index: index,
        ),
      ),
    );

    if (result == true) {
      context.read<RouletteBloc>().add(LoadPrizes());
      Navigator.pop(context, true); // Navigate back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Prizes')),
      body: ListView.builder(
        itemCount: _prizes.length,
        itemBuilder: (context, index) {
          final prize = _prizes[index];
          return ListTile(
            title: Text(prize.name),
            subtitle: Text('Percentage: ${prize.percentage}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPrize(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePrize(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPrizePage()),
          );
          if (result == true) {
            context.read<RouletteBloc>().add(LoadPrizes());
            Navigator.pop(context, true); // Navigate back to the previous screen
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
