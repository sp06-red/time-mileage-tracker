import 'SavedLocationsManager.dart';

class Settings{
  int pollRate = 5;
  List<SavedLocation> savedLocations =  <SavedLocation>[];
  bool metric = false;
  bool autoTag = false;
  bool followDeviceTheme = false;

  Settings(this.pollRate, this.savedLocations, this.metric, this.autoTag, this.followDeviceTheme);

  Settings.stock();

  Settings.from(Settings settings){
    pollRate = settings.pollRate;
    savedLocations = settings.savedLocations;
    metric = settings.metric;
    autoTag = settings.autoTag;
    followDeviceTheme = settings.followDeviceTheme;
  }

  Settings.fromJson(String path){}
}