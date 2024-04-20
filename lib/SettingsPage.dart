
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:time_mileage_tracker/EntryListManager.dart';
import 'Settings.dart';
import 'SavedLocationsManager.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({
    super.key,
    required this.settings,
    required this.entryListManager,
    required this.savedLocationsManager,
    this.child,
  });

  final EntryListManager entryListManager;
  final SavedLocationManager savedLocationsManager;
  final Settings settings;
  final Widget? child;

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  late Settings settings;
  late EntryListManager listManager;
  late SavedLocationManager savedLocationsManager;
  late var value;

  @override
  void initState() {
    super.initState();
    settings = Settings.from(widget.settings);
    listManager = widget.entryListManager;
    value = [settings, listManager];
    savedLocationsManager = widget.savedLocationsManager;
  }

  Widget _savedLocationsList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: savedLocationsManager.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 3),
          child: Card(
            child: ListTile(
              title: Row(
                children: [
                  Text(savedLocationsManager.at(index).toString()),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      savedLocationsManager.remove(savedLocationsManager
                          .at(index)
                          .hashCode);
                      setState(() { /* contents of list changed */});
                    }
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _savedLocationsEditor() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Saved Locations"),
              content: SizedBox(
                width: 300,
                height: 300,
                child: _savedLocationsList(),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                ),
              ]
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Account"),
            tiles: [
              SettingsTile(
                title: const Text('Sign in for sync'),
                leading: const Icon(Icons.login),
                onPressed: (BuildContext context){}
              )
            ],
          ),
          SettingsSection(
            title: const Text("General"),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Follow device theme'),
                leading: const Icon(Icons.format_paint_sharp),
                initialValue: settings.followDeviceTheme,
                onToggle: (bool value) {
                  setState(() {
                    settings.followDeviceTheme = value;
                  });
                },
              ),
              SettingsTile(
                title: const Text('Set unit preference'),
                description: const Text("Imperial (Miles)"),
                leading: const Icon(Icons.straighten),
                onPressed: (BuildContext context){
                },
              ),
    ]
    ),
    SettingsSection(
      title: const Text("GPS and Location"),
      tiles: [
              SettingsTile.switchTile(
                title: const Text('Auto-tag locations'),
                leading: const Icon(Icons.tag),
                initialValue: settings.autoTag,
                onToggle: (bool value) {
                  setState(() {
                    settings.autoTag = value;
                  });
                },
              ),
              SettingsTile(
                title: const Text('Auto-tag location list'),
                description: const Text("Modify saved locations to automatically apply tags according to start/end locations"),
                leading: const Icon(Icons.edit_location_alt),
                onPressed: (BuildContext context){
                  _savedLocationsEditor();
                },
              ),
              SettingsTile(
                title: const Text('GPS Poll Rate'),
                description: const Text("5s"),
                leading: const Icon(Icons.timer_outlined),
                onPressed: (BuildContext context){
                },
              )
            ],
          ),
          SettingsSection(
            title: const Text("Danger Zone"),
            tiles: [
              SettingsTile(
                  title: const Text('Flush List'),
                  description: const Text("Deletes all entries in entry list"),
                  leading: const Icon(Icons.delete),
                onPressed: (BuildContext context){
                    listManager.wipe();
                    value[1] = listManager;
                },
              )
            ],
          ),
        ],
      ),
      floatingActionButton: 
      Card(
        child: IconButton(
          icon: Icon(Icons.save),
          onPressed: () {
            Navigator.pop(context, value);
          },
        ),
      ),
    );
  }
}