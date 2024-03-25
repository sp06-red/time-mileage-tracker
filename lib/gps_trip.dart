import 'package:geolocator/geolocator.dart'; // For geolocation features
import 'entry.dart'; // For the Entry class
import 'dart:async'; // For asynchronous programming

// Defining the GPSTrip class
class GPSTrip {
  // Declaring variables
  late DateTime start; // Start time of the trip
  late DateTime end; // End time of the trip
  late Position last; // Start position of the trip
  double totalDistance = 0.0; // Total distance of the trip
  StreamSubscription<Position>? positionStreamSubscription; // Subscription to the position stream

  final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
      /*foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText:
        "Example app will continue to receive your location even when you aren't using it",
        notificationTitle: "Running in Background",
        enableWakeLock: true,
      )*/
  );

  GPSTrip();

  Future<void> permissionCheck() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  // Method to start the trip
  void startTrip() async {
    start = DateTime.now();
    permissionCheck();
    last = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _trackLocation();
  }

  // Method to end the trip
  Future<Entry> endTrip() async {
    end = DateTime.now(); // Set the end time to the current time
    positionStreamSubscription?.cancel(); // Cancel the position stream subscription
    positionStreamSubscription = null; // Set the subscription to null after cancelling
    Entry out = Entry(start,end,totalDistance);
    totalDistance=0;
    return out;
  }

  // Method to track the location during the trip
  Future<void> _trackLocation() async {
      positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position current) { // Subscribe to the position stream
        try{
          double distance = Geolocator.distanceBetween( // Calculate the distance between the start position and the current position
            last.latitude,
            last.longitude,
            current.latitude,
            current.longitude,
          );
          totalDistance += distance*0.000621371; // Convert distance to *miles* then add to total distance
          last = current; // Update the start position to the current position
          print('Current location: $current'); // Print the current location
          print('Current distance: $totalDistance'); // Print the current distance
        } catch (e){
          last=current;
        }
    });
  }
}