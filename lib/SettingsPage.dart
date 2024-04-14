import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Saved Locations"),
            tiles: [
              SettingsTile(
                title: const Text('Auto-tag locations'),
                description: const Text("Modify saved locations to automatically apply tags based on trip start/end locations"),
                leading: const Icon(Icons.location_pin),
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
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}