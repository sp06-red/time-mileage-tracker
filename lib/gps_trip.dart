import 'package:geolocator/geolocator.dart';
import 'entry.dart';

class GPSTrip {
  late DateTime start;
  late DateTime end;
  late Position startPosition;
  late Position endPosition;
  double totalDistance = 0.0;

  Future<void> startTrip() async {
    start = DateTime.now();
    startPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> trackLocation() async {
    Geolocator.getPositionStream().listen((Position position) async {
      double distance = Geolocator.distanceBetween(
        startPosition.latitude,
        startPosition.longitude,
        position.latitude,
        position.longitude,
      );
      totalDistance += distance;
      startPosition = position;
      print('Current location: $position');
      print('Current distance: $totalDistance');
      await Future.delayed(Duration(seconds: 10));
    });
  }

  Future<void> endTrip() async {
    end = DateTime.now();
    endPosition = await Geolocator.getCurrentPosition();
    double distance = Geolocator.distanceBetween(
      startPosition.latitude,
      startPosition.longitude,
      endPosition.latitude,
      endPosition.longitude,
    );
    totalDistance += distance;
  }

  Entry getEntry() {
    return Entry(start, end, totalDistance.toInt());
  }
}