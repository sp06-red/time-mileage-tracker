import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_mileage_tracker/entry.dart';
import 'gps_trip.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'entry_list_manager.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.title});
  final String title;
  @override
  State<EntryView> createState() => _EntryView();
}

class _EntryView extends State<EntryView> {
  EntryListManager listManager = EntryListManager();
  GPSTrip gpsTrip = GPSTrip();
  bool isTracking = false;

  void _AddEntry() async {
    DateTime? start;
    DateTime? end;
    int? mileage;
    List<String> taglist = <String>[];

    if (isTracking) {
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Entry'),
          content: Column(
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onConfirm: (date) {
                      start = date;
                    });
                  },
                  child: const Text(
                    "Select start time",
                    style: TextStyle(color: Colors.blue),
                  )),
              TextButton(
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onConfirm: (date) {
                      end = date;
                    });
                  },
                  child: const Text(
                    "Select end time",
                    style: TextStyle(color: Colors.blue),
                  )),
              TextField(
                onChanged: (value) {
                  mileage = int.parse(value);
                },
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
                  listManager.addEntry(temp);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _EditEntry(Entry entry, int index) async {
    DateTime? start = entry.start;
    DateTime? end = entry.end;
    int? mileage = entry.mileage;
    List<String> taglist = entry.getTags();

    // Create TextEditingController for each TextField
    TextEditingController mileageController =
        TextEditingController(text: mileage.toString());
    TextEditingController tagsController =
        TextEditingController(text: taglist.join(' '));

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Entry'),
          content: Column(
            children: <Widget>[
              // Button for selecting the start time
              TextButton(
                  onPressed: () {
                    // Show a date time picker when the button is pressed
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onConfirm: (date) {
                      // When a date is selected, update the start time
                      start = date;
                    });
                  },
                  child: const Text(
                    "Select start time",
                    style: TextStyle(color: Colors.blue),
                  )),
              // Button for selecting the end time
              TextButton(
                  onPressed: () {
                    // Show a date time picker when the button is pressed
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onConfirm: (date) {
                      // When a date is selected, update the end time
                      end = date;
                    });
                  },
                  child: const Text(
                    "Select end time",
                    style: TextStyle(color: Colors.blue),
                  )),
              // TextField for entering the mileage
              TextField(
                controller: mileageController, // Set the controller
                onChanged: (value) {
                  // When the text changes, update the mileage
                  mileage = int.parse(value);
                },
                decoration: InputDecoration(hintText: "Enter mileage"),
              ),
              // TextField for entering the tags
              TextField(
                controller: tagsController, // Set the controller
                onChanged: (value) {
                  // When the text changes, update the tags
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
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                if (start != null && end != null && mileage != null) {
                  // Update the Entry object with the new values
                  entry.start = start!;
                  entry.end = end!;
                  entry.mileage = mileage!;
                  entry.retag(taglist);
                  entry.duration = entry.end.difference(entry.start);
                  listManager.addEntry(entry);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleGPSTracking() async {
    if (isTracking) {
      isTracking = false;
      await gpsTrip.endTrip();
      listManager.addEntry(gpsTrip.getEntry());
    } else {
      isTracking = true;
      gpsTrip = GPSTrip();
      await gpsTrip.trackLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: listManager.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.local_taxi),
            title: Text(listManager.at(index).toString()),
            onTap: () => _EditEntry(listManager.at(index), index),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _toggleGPSTracking();
                });
              }),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _AddEntry();
                });
              })
        ],
      )),
    );
  }
}
