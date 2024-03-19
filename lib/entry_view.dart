import 'package:flutter/material.dart';
import 'entry.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.title});
  final String title;
  @override
  State<EntryView> createState() => _EntryView();
}

class _EntryView extends State<EntryView> {
  ValueNotifier<List<Entry>> entryLog = ValueNotifier<List<Entry>>([]);

  void _AddEntry() async {
    DateTime? start;
    DateTime? end;
    int? mileage;
    List<String> taglist = <String>[];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Entry'),
          content: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) { start = DateTime.parse(value); },
                decoration: InputDecoration(hintText: "Enter start time (yyyy-mm-ddThh:mm)"),
              ),
              TextField(
                onChanged: (value) { end = DateTime.parse(value); },
                decoration: InputDecoration(hintText: "Enter end time (yyyy-mm-ddThh:mm)"),
              ),
              TextField(
                onChanged: (value) { mileage = int.parse(value); },
                decoration: InputDecoration(hintText: "Enter mileage"),
              ),
              TextField(
                onChanged: (value) {
                  String n = value;
                  taglist = n.split(' ');
                },
                decoration: InputDecoration(hintText: "Enter tags (Optional)"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (start != null && end != null && mileage != null) {
                  // Create a new Entry object using the parsed start time, end time, and mileage
                  Entry temp = Entry(start!, end!, mileage!);
                  temp.retag(taglist);
                  // Create a new list that includes the new Entry
                  List<Entry> newList = List.from(entryLog.value)..add(temp);
                  // Assign the new list to the ValueNotifier
                  entryLog.value = newList;
                  // Print the entryLog to the console for debugging
                  print(entryLog.value);
                  Navigator.of(context).pop();
                }
              },
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
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder( // Wrap the ListView in a ValueListenableBuilder
        valueListenable: entryLog, // Listen to changes in entryLog
        builder: (BuildContext context, List<Entry> value, Widget? child) {
          return ListView(
            children: [
              for (Entry entry in value)
                ListTile(
                  leading: Icon(Icons.local_taxi),
                  title: Text(entry.toString()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _AddEntry,
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}