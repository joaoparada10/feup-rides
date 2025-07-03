import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../event.dart';
import '../utilities/map_utilities.dart';

Future<DocumentSnapshot?> fetchNextRide(String userUid) async {
  try {
    // Query for rides where userUid is the driver
    print("Querying for driver rides...");
    QuerySnapshot driverQuerySnapshot = await FirebaseFirestore.instance
        .collection('Rides')
        .where('DriverUid', isEqualTo: userUid)
        .where('EndTime', isGreaterThan: Timestamp.now())
        .orderBy('EndTime')
        .limit(1)
        .get();
    print("Driver rides fetched: ${driverQuerySnapshot.docs.length}");

    // Query for rides where userUid is a passenger
    print("Querying for passenger rides...");
    QuerySnapshot passengerQuerySnapshot = await FirebaseFirestore.instance
        .collection('Rides')
        .where('Passengers', arrayContains: userUid)
        .where('EndTime', isGreaterThan: Timestamp.now())
        .orderBy('EndTime')
        .limit(1)
        .get();
    print("Passenger rides fetched: ${passengerQuerySnapshot.docs.length}");

    // Combine the results
    List<DocumentSnapshot> allRides = []
      ..addAll(driverQuerySnapshot.docs)
      ..addAll(passengerQuerySnapshot.docs);
    print("Total rides fetched: ${allRides.length}");

    // Sort the rides by start time
    allRides.sort((a, b) =>
        ((a.data() as Map<String, dynamic>)['StartTime'] as Timestamp)
            .compareTo(
                (b.data() as Map<String, dynamic>)['StartTime'] as Timestamp));
    
    if (allRides.isNotEmpty) {
      print("Returning the first ride...");
      return allRides.first;
    } else {
      print("No rides found.");
      return null; // return null if there's no next ride
    }
  } catch (e, stacktrace) {
    print("Error fetching next ride: $e");
    print("Stacktrace: $stacktrace");
    return null;
  }
}

Future<void> createRideSchedule(Ride _ride, String userId, BuildContext context) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    String firstName = userSnapshot['firstName'] ?? '';
    String lastName = userSnapshot['lastName'] ?? '';
    String driverName = '$firstName $lastName';

    final rideData = {
      'Origin': _ride.origin,
      'Destination': _ride.destination,
      'OriginPoint' : await getGeoPoint(_ride.origin),
      'DestinationPoint' : await getGeoPoint(_ride.destination),
      'DriverUid': userId,
      'Driver': driverName,
      'EmptySeats': _ride.emptySeats,
      'StartTime': Timestamp.fromDate(_ride.startTime),
      'EndTime': Timestamp.fromDate(_ride.endTime),
    };

    FirebaseFirestore.instance.collection('Rides').add(rideData)
        .then((docRef) {
      String rideId = docRef.id;
      _ride.rideId = rideId;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ride created successfully')));
    })
        .catchError((error) {
      print("Failed to create ride: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create ride')));
    });
  }

  