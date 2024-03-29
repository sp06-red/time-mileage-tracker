import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_mileage_tracker/entry.dart';
import 'gps_trip.dart';
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
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
    listManager = EntryListManager();
    await Future.delayed(Duration(milliseconds: 333));
    setState(() {});
  }

  void _filter() async {
    List<Entry> list = listManager.entryList;

    // get maximum/minimum distances
    double minDist = list.first.mileage;
    double maxDist = minDist;
    for (int i = 0; i != list.length; i++) {
      if (list[i].mileage < minDist) minDist = list[i].mileage;
      if (list[i].mileage > maxDist) maxDist = list[i].mileage;
    }
    RangeValues distRange = RangeValues(minDist, maxDist);

    DateTimeRange dateRangeSelection =
        DateTimeRange(start: list.last.start, end: list.first.end);
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Filter"),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Card(
                    child: SizedBox(
                  width: 600,
                  child: TextButton(
                    child: Text(
                        "${DateFormat.MMMd().format(dateRangeSelection.start)} to ${DateFormat.MMMd().format(dateRangeSelection.end)}"),
                    onPressed: () async {
                      dateRangeSelection = (await showDateRangePicker(
                          context: context,
                          firstDate: list.last.start,
                          lastDate: list.first.start))!;
                      print(dateRangeSelection.start.toString());
                      setState;
                    },
                  ),
                )),
                /* Distance Range Slider */
                Card(
                  child: Column(
                    children: [
                      const Text("Distance"),
                      RangeSlider(
                        min: minDist,
                        max: maxDist,
                        divisions: ((maxDist - minDist) / 5).round(),
                        values: distRange,
                        labels: RangeLabels(
                          distRange.start.round().toString(),
                          distRange.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() => distRange = values);
                        },
                      ),
                    ],
                  ),
                ),
              ]);
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Apply")),
            ],
          );
        });
  }

  void _addEntry() async {
    DateTime? start;
    DateTime? end;
    double? mileage;
    List<String> tagList = <String>[];

    if (isTracking) {
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
                  mileage = double.parse(value);
                },
                decoration: const InputDecoration(hintText: "Enter mileage"),
              ),
              TextField(
                onChanged: (value) {
                  String n = value;
                  tagList = n.split(' ');
                },
                decoration:
                    const InputDecoration(hintText: "Enter tags (Optional)"),
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
              child: const Text('Add'),
              onPressed: () {
                if (start != null && end != null && mileage != null) {
                  // Create a new Entry object using the parsed start time, end time, and mileage
                  Entry temp = Entry(start!, end!, mileage!);
                  temp.retag(tagList);
                  listManager.addEntry(temp);
                  setState(() {/* Contents of entry list changed */});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editEntry(Entry entry, int index) async {
    DateTime? start = entry.start;
    DateTime? end = entry.end;
    double? mileage = entry.mileage;
    List<String> tagList = entry.tagList;

    // Create TextEditingController for each TextField
    TextEditingController mileageController =
        TextEditingController(text: mileage.toStringAsFixed(2));
    TextEditingController tagsController =
        TextEditingController(text: tagList.join(' '));

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
                  mileage = double.parse(value);
                },
                decoration: const InputDecoration(hintText: "Enter mileage"),
              ),
              // TextField for entering the tags
              TextField(
                controller: tagsController, // Set the controller
                onChanged: (value) {
                  // When the text changes, update the tags
                  String n = value;
                  tagList = n.split(' ');
                },
                decoration:
                    const InputDecoration(hintText: "Enter tags (Optional)"),
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
              child: const Text('Delete'),
              onPressed: () {
                listManager.removeEntry(entry.hashCode);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                if (start != null && end != null && mileage != null) {
                  // Update the Entry object with the new values
                  listManager.removeEntry(entry.hashCode);
                  entry.start = start!;
                  entry.end = end!;
                  entry.mileage = mileage!;
                  entry.retag(tagList);
                  entry.duration = entry.end.difference(entry.start);
                  listManager.addEntry(entry);
                  setState(() {/* Contents of entry list changed */});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  GPSTrip gpsTrip = GPSTrip();
  void _toggleGPSTracking() async {
    if (isTracking) {
      isTracking = false;
      listManager.addEntry(await gpsTrip.endTrip());
    } else {
      isTracking = true;
      gpsTrip.startTrip();
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: listManager.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 3),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.local_taxi),
                title: Text(listManager.at(index).toString()),
                onTap: () => _editEntry(listManager.at(index), index),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* GPS toggle switch */
          Card(
            child: IconButton(
                icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _toggleGPSTracking();
                  });
                }),
          ),
          /* Manual entry add */
          Card(
            child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _addEntry();
                }),
          ),
          /* Flush list */
          Card(
              child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                listManager.wipe();
              });
            },
          )),
          /* Filter */
          Card(
              child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _filter();
              });
            },
          )),
        ],
      )),
    );
  }
}
