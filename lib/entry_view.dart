import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter/material.dart';
import 'entry.dart';
import 'gps_trip.dart';
import 'package:permission_handler/permission_handler.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.title});
  final String title;
  @override
  State<EntryView> createState() => _EntryView();
}

class _EntryView extends State<EntryView> {
  ValueNotifier<List<Entry>> entryLog = ValueNotifier<List<Entry>>([]);
  GPSTrip gpsTrip = GPSTrip();

  void _AddEntry() async {
    DateTime? start;
    DateTime? end;
    int? mileage;
    List<String> taglist = <String>[];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Entry'),
          content: Column(
            children: <Widget>[
              TextButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      onChanged: (date){
                        start = date;
                      });
                  },
                child: const Text(
                    "Select start time",
                    style: TextStyle(color: Colors.blue),
                )
              ),
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onChanged: (date){
                          end = date;
                        });
                  },
                  child: const Text(
                    "Select end time",
                    style: TextStyle(color: Colors.blue),
                  )
              ),
              TextField(
                onChanged: (value) { mileage = int.parse(value); },
                decoration: const InputDecoration(hintText: "Enter mileage"),
              ),
              TextField(
                onChanged: (value) {
                  String n = value;
                  taglist = n.split(' ');
                },
                decoration: const InputDecoration(hintText: "Enter tags (Optional)"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: entryLog,
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
          ),
          ElevatedButton(
            onPressed: () async {
              PermissionStatus status = await gpsTrip.startTrip();
              if (!status.isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location permission is not granted')),
                );
              } else {
                await gpsTrip.trackLocation();
              }

              await gpsTrip.startTrip();
              await gpsTrip.trackLocation();
            },
            child: Text('Start Trip'),
          ),
          ElevatedButton(
            onPressed: () async {
              await gpsTrip.endTrip();
              Entry entry = gpsTrip.getEntry();
              entryLog.value = List.from(entryLog.value)..add(entry);
            },
            child: Text('End Trip'),
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