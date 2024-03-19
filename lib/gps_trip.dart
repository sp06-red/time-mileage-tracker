import 'package:geolocator/geolocator.dart';
import 'entry.dart';
import 'package:permission_handler/permission_handler.dart';

class GPSTrip {
  late DateTime start;
  late DateTime end;
  late Position startPosition;
  late Position endPosition;
  double totalDistance = 0.0;

  Future<PermissionStatus> startTrip() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      start = DateTime.now();
      startPosition = await Geolocator.getCurrentPosition();
    } else {
      print('Location permission is not granted');
    }
    return status;
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