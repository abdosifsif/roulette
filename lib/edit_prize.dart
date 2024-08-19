import 'package:app_roulette/bloc/app_roulette_event.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_roulette/add_prize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_roulette/bloc/app_roulette_bloc.dart';

class EditPrizesPage extends StatefulWidget {
  final int index;
  final String currentPrize;

  const EditPrizesPage({Key? key, required this.index, required this.currentPrize}) : super(key: key);

  @override
  _EditPrizesPageState createState() => _EditPrizesPageState();
}

class _EditPrizesPageState extends State<EditPrizesPage> {
  late List<String> _prizes;

  @override
  void initState() {
    super.initState();
    _loadPrizes();
  }

  Future<void> _loadPrizes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _prizes = prefs.getStringList('prizes') ?? [];
    });
  }

  Future<void> _deletePrize(int index) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this prize?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _prizes.removeAt(index);
      await prefs.setStringList('prizes', _prizes);
      context.read<RouletteBloc>().add(LoadPrizes()); // Notify the bloc to reload prizes
      Navigator.pop(context, true); // Notify success
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
      context.read<RouletteBloc>().add(LoadPrizes()); // Reload prizes after editing
      Navigator.pop(context, true); // Return to home if prize was edited
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Prizes')),
      body: ListView.builder(
        itemCount: _prizes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_prizes[index]),
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
            context.read<RouletteBloc>().add(LoadPrizes()); // Reload prizes after adding
            Navigator.pop(context, true); // Return to home if a prize was added
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
