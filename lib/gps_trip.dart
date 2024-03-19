// Importing necessary packages
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

  // Method to start the trip
  Future<PermissionStatus> startTrip() async {
    PermissionStatus status = await Permission.location.request(); // Requesting location permission
    if (status.isGranted) { // If permission is granted
      start = DateTime.now(); // Set the start time to the current time
      startPosition = await Geolocator.getCurrentPosition(); // Get the current position
    } else { // If permission is not granted
      print('Location permission is not granted'); // Print a message
    }
    return status; // Return the permission status
  }

  // Method to end the trip
  Future<void> endTrip() async {
    end = DateTime.now(); // Set the end time to the current time
    endPosition = await Geolocator.getCurrentPosition(); // Get the current position
    double distance = Geolocator.distanceBetween( // Calculate the distance between the start and end positions
      startPosition.latitude,
      startPosition.longitude,
      endPosition.latitude,
      endPosition.longitude,
    );
    totalDistance += distance; // Add the distance to the total distance
    positionStreamSubscription?.cancel(); // Cancel the position stream subscription
    positionStreamSubscription = null; // Set the subscription to null after cancelling
  }

  // Method to track the location during the trip
  Future<void> trackLocation() async {
    positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) { // Subscribe to the position stream
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