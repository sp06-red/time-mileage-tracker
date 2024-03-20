// Importing necessary packages
import 'dart:io';

import 'package:geolocator/geolocator.dart'; // For geolocation features
import 'entry.dart'; // For the Entry class
import 'package:permission_handler/permission_handler.dart'; // For permission handling
import 'dart:async'; // For asynchronous programming
import 'package:flutter/material.dart'; // For Flutter's Material Design widgets

// Defining the GPSTrip class
class GPSTrip {
  // Declaring variables
  late DateTime start; // Start time of the trip
  late DateTime end; // End time of the trip
  late Position startPosition; // Start position of the trip
  late Position endPosition; // End position of the trip
  double totalDistance = 0.0; // Total distance of the trip
  StreamSubscription<Position>? positionStreamSubscription; // Subscription to the position stream

  GPSTrip(){
    start = DateTime.now();
    startTrip();
  }

  Future<bool> getPermissionStatus() async {
    LocationPermission status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied){
      return false;
    } else {
      return true;
    }
  }
  Future<Position> _determinePosition() async {
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  }


  // Method to start the trip
  void startTrip() async {
    start = DateTime.now();
    startPosition = await _determinePosition(); // Get the current position with high accuracy
  }

  // Method to end the trip
  Future<void> endTrip() async {
    end = DateTime.now(); // Set the end time to the current time
    positionStreamSubscription?.cancel(); // Cancel the position stream subscription
    positionStreamSubscription = null; // Set the subscription to null after cancelling
  }

  // Method to track the location during the trip
  Future<void> trackLocation() async {
    positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) { // Subscribe to the position stream
      sleep(const Duration(seconds:3));
      double distance = Geolocator.distanceBetween( // Calculate the distance between the start position and the current position
        startPosition.latitude,
        startPosition.longitude,
        position.latitude,
        position.longitude,
      );
      totalDistance += distance; // Add the distance to the total distance
      startPosition = position; // Update the start position to the current position
      print('Current location: $position'); // Print the current location
      print('Current distance: $totalDistance'); // Print the current distance
    });
  }

  // Method to get an Entry object for the trip
  Entry getEntry() {
    return Entry(start, end, totalDistance.toInt()); // Create an Entry object with the start time, end time, and total distance
  }
}