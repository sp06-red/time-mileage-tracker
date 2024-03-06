import 'package:flutter/material.dart';
import 'entry.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.title});
  final String title;
  @override
  State<EntryView> createState() => _EntryView();
}

class _EntryView extends State<EntryView> {
  List<Entry> entryLog = [];

  void _AddEntry() {
    Entry temp = Entry(DateTime.now(), DateTime.now(), 10);
    setState(() {
      entryLog.add(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          for (Entry entry in entryLog)
            ListTile(
              leading: Icon(Icons.local_taxi),
              title: Text(entry.toString()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _AddEntry,
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}