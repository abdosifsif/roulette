import 'package:app_roulette/add_prize.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPrizesPage extends StatefulWidget {
  const EditPrizesPage({Key? key}) : super(key: key);

  @override
  _EditPrizesPageState createState() => _EditPrizesPageState();
}

class _EditPrizesPageState extends State<EditPrizesPage> {
  List<String> prizes = [];

  @override
  void initState() {
    super.initState();
    _loadPrizes();
  }

  Future<void> _loadPrizes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prizes = prefs.getStringList('prizes') ?? [];
    });
  }

  Future<void> _deletePrize(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prizes.removeAt(index);
    await prefs.setStringList('prizes', prizes);
    _loadPrizes();
  }

  Future<void> _editPrize(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPrizePage(prize: prizes[index], index: index)),
    );
    if (result == true) {
      _loadPrizes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Prizes')),
      body: ListView.builder(
        itemCount: prizes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(prizes[index]),
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
            _loadPrizes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
