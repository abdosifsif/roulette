import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPrizePage extends StatefulWidget {
  final String? prize;
  final int? index;

  const AddPrizePage({Key? key, this.prize, this.index}) : super(key: key);

  @override
  _AddPrizePageState createState() => _AddPrizePageState();
}

class _AddPrizePageState extends State<AddPrizePage> {
  final TextEditingController _prizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prize != null) {
      _prizeController.text = widget.prize!;
    }
  }

  Future<void> _savePrize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? prizes = prefs.getStringList('prizes') ?? [];
    
    if (widget.index != null) {
      prizes[widget.index!] = _prizeController.text;
    } else {
      prizes.add(_prizeController.text);
    }

    await prefs.setStringList('prizes', prizes);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.prize == null ? 'Add Prize' : 'Edit Prize')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _prizeController,
              decoration: InputDecoration(labelText: 'Prize Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePrize,
              child: Text(widget.prize == null ? 'Add Prize' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
