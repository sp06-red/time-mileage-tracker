import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'SettingsManager.dart';


class SettingsPage extends StatefulWidget{
  const SettingsPage({
    super.key,
    required this.settings,
    this.child,
  });

  final Settings settings;
  final Widget? child;

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  late Settings settings;

  @override
  void initState() {
    super.initState();
    settings = Settings.from(widget.settings);
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
          },
        ),
      ),
    );
  }
}