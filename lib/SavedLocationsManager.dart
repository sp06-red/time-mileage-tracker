import 'package:geolocator/geolocator.dart'; // For geolocation features
import 'dart:math';

class SavedLocation{
  late String label;
  late Position location;

  SavedLocation(this.label, this.location);

  @override
  String toString() {
    return "$label ${location.latitude.toStringAsFixed(4)} ${location.longitude.toStringAsFixed(4)}";
  }

  get position{
    return location;
  }
}

class SavedLocationManager{
  late List<SavedLocation> locations;

  SavedLocationManager(){
    locations = <SavedLocation>[];
  }

  at(int index){
    return locations[index];
  }

  int get length{
    return locations.length;
  }

  remove(int hashCode){
    for(int i = 0; i != locations.length; i++) {
      if (locations[i].hashCode == hashCode) {
        locations.removeAt(i);
        return;
      }
    }
  }

  String listContains(Position coordinates){
    for(SavedLocation location in locations){
      Position temp = location.position;
      if(Geolocator.distanceBetween(temp.latitude, temp.longitude, coordinates.latitude, coordinates.longitude) <= 10){
        return location.label;
      }
    }
    return "-1";
  }

  void add(SavedLocation location){
    locations.add(location);
  }
}