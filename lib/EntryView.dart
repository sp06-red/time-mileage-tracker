import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_mileage_tracker/Entry.dart';
import 'package:time_mileage_tracker/SavedLocationsManager.dart';
import 'gps_trip.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'EntryListManager.dart';
import 'FilterOptions.dart';
import 'SettingsPage.dart';
import 'Settings.dart';
import 'package:geolocator/geolocator.dart'; // For geolocation features

class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.title});
  final String title;
  @override
  State<EntryView> createState() => _EntryView();
}

class _EntryView extends State<EntryView> {
  EntryListManager listManager = EntryListManager();
  bool isTracking = false;
  late FilterOptions filterOptions;
  Settings settings = Settings.stock();
  late SavedLocationManager savedLocationManager;

  @override
  void initState() {
    super.initState();
    setup();
    savedLocationManager = SavedLocationManager();
  }

  Future<void> setup() async {
    listManager = EntryListManager();
    await Future.delayed(const Duration(milliseconds: 333));
    filterOptions = FilterOptions(listManager.globalList);
    setState(() {});
  }

  void _filter() async{
    if(listManager.isGlobal){
      filterOptions!.reset(listManager.globalList);
    }

    List<Entry> list = listManager.globalList;
    double minDist = list.first.mileage;
    double maxDist = minDist;
    for (int i = 0; i != list.length; i++) {
      if (list[i].mileage < minDist) minDist = list[i].mileage;
      if (list[i].mileage > maxDist) maxDist = list[i].mileage;
    }
    // Create TextEditingController for each TextField
    TextEditingController tags = TextEditingController(text: filterOptions!.tagList.join(' ') );

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
                        "${DateFormat.MMMd().format(filterOptions!.dateFilter!.start)} to ${DateFormat.MMMd().format(filterOptions!.dateFilter!.end)}"),
                    onPressed: () async {
                      filterOptions.dateFilter = (await showDateRangePicker(
                          context: context,
                          firstDate: listManager.globalList.last.start,
                          lastDate: listManager.globalList.first.end.add(const Duration(days:1))))!;
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
                        divisions: 20,
                        values: filterOptions!.distanceFilter,
                        labels: RangeLabels(
                          filterOptions!.distanceFilter.start.round().toString(),
                          filterOptions!.distanceFilter.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() => filterOptions?.distanceFilter = values);
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                    child: TextField(
                  controller: tags,
                      onChanged: (value) {
                    filterOptions!.tagList = value.split(' ');
                  },
                  decoration: const InputDecoration(hintText: "Tags: "),
                ))
              ]);
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      filterOptions?.reset(listManager.globalList);
                      listManager.reset();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Reset")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      listManager.buildFilterListFromOptions(filterOptions!);
                    });
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
                listManager.buildFilterList(filterOptions!.dateFilter, filterOptions!.distanceFilter, filterOptions!.tagList);
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

  void _newLocationDialog() async {
    String locationName="";
    Position location = await gpsTrip.getLocation();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Add to Auto-tag List"),
              content: Column(
                children: [
                  Text("Naming ${location.longitude.toStringAsFixed(4)}:${location.latitude.toStringAsFixed(4)}"),
                  TextField(
                  onChanged: (value) {
                    locationName = value;
                  },
                  decoration: const InputDecoration(hintText: "Location name"),
                ),
        ]
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                ),
                TextButton(
                    child: const Text('Save'),
                    onPressed: () async {
                      String existing_location = savedLocationManager.listContains(location);
                      if(existing_location == "-1"){
                        savedLocationManager.add(SavedLocation(locationName, location));
                        Navigator.of(context).pop();
                      }
                      else{
                        showDialog(
                            context: context,
                            builder: (BuildContext ctxt){
                              return AlertDialog(
                                content: Text("Location already in list\nNamed: $existing_location"),
                                actions: [
                                  TextButton(
                                     child: const Text("ok :("),
                                    onPressed: () { Navigator.of(context).pop(); },
                                  )
                                ],
                              );
                            }
                        );
                      }
                    }
                ),
              ]
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:() async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(savedLocationsManager: savedLocationManager, settings: settings, entryListManager: listManager)),
                );
              settings = result[0];
              listManager = result[1];
              setState(() {});
            }
          )
        ]
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
          if (isTracking) ElevatedButton.icon(
              label: const Text("Stop GPS Entry"),
              icon: const Icon(Icons.gps_off),
              onPressed: () {
                setState(() {
                  _toggleGPSTracking();
                });
              }),
          if( !isTracking ) Card(
            child: IconButton(
                icon: const Icon(Icons.gps_fixed),
                onPressed: () {
                  setState(() {
                    _toggleGPSTracking();
                  });
                }),
          ),
          /* Manual entry add */
          if( !isTracking ) Card(
            child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _addEntry();
                }),
          ),
          /* Add new location tag */
          if( !isTracking ) Card(
              child: IconButton(
                icon: const Icon(Icons.add_location_alt),
                onPressed: () {
                  _newLocationDialog();
                },
              )),
          /* Filter */
          if( !isTracking ) Card(
              child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _filter();
              });
            },
          )),
          /* export */
          if( !isTracking ) Card(
              child: IconButton(
                icon: const Icon(Icons.file_upload_sharp),
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
