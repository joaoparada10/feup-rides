import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feup_rides/location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'utilities/place.dart';
import 'utilities/map_utilities.dart';
import 'utilities/date_time_utilities.dart';
import 'database/ride_fetching.dart';

class MapPage extends StatefulWidget {
  final String userUid;
  DocumentSnapshot? rideSnapshot;

  MapPage({
    Key? key,
    required this.userUid,
    this.rideSnapshot,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  Set<Polyline> _polylines = {};
  LatLng _initialPosition = const LatLng(41.1780, -8.5980);
  Future<LatLng>? locationFuture;
  bool _nextRide = false;
  DocumentSnapshot? _rideSnapshot;
  GeoPoint? _originPoint;
  GeoPoint? _destinationPoint;
  StreamSubscription<Position>? positionStream;
  final List<LatLng> _pickupPoints = [
    const LatLng(41.17771095118023, -8.59847765130881), // FEUP MAIN ENTRANCE
    const LatLng(41.17706031097826, -8.59429269872504), // FEUP PARQUE ALUNOS
    const LatLng(41.17371493484103, -8.603748692522272), // POLO UNIVERSITARIO
    const LatLng(41.18124805917921, -8.60466596334133), // IPO
    const LatLng(41.15824373657729, -8.630371622609543), // CASA DA MUSICA
    const LatLng(41.15186230905047, -8.609737753777752), // TRINDADE
  ];
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _rideSnapshot = widget.rideSnapshot;
    _startTracking();
    locationFuture = getCurrentLocation();
    if (_rideSnapshot == null) {
      fetchNextRide(widget.userUid).then((snapshot) {
        print("Fetched snapshot: $snapshot");
        setState(() {
          _rideSnapshot = snapshot;
          if (_rideSnapshot != null) {
            print("Ride snapshot is not null");
            _originPoint = _rideSnapshot!['OriginPoint'];
            _destinationPoint = _rideSnapshot!['DestinationPoint'];
            _drawRoute();
            _nextRide = true;
          }
        });
      }).catchError((error) {
        print("Error occurred in then block: $error");
      });
    } else {
      _originPoint = _rideSnapshot!['OriginPoint'];
      _destinationPoint = _rideSnapshot!['DestinationPoint'];
      _drawRoute();
      _nextRide = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    positionStream?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _pickupPoints.forEach((point) {
      _addMarker(point);
    });
  }

  void _startTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null) {
          setState(() {
            _markers.add(
              Marker(
                markerId: const MarkerId('userLocation'),
                position: LatLng(position.latitude, position.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            );
          });
        }
      },
    );
  }

  void _addMarker(LatLng position) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: const InfoWindow(
        title: 'Pickup Point',
        snippet: 'This is a pre-defined pickup point.',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  void _drawRoute() async {
    if (_originPoint != null && _destinationPoint != null) {
      print("Getting route from $_originPoint to $_destinationPoint");
      String route = await getRoute(_originPoint!, _destinationPoint!);
      print("Encoded route: $route");

      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(route);
      print("Decoded polyline points: $decodedPolylinePointsResult");

      if (decodedPolylinePointsResult.isNotEmpty) {
        List<LatLng> routePoints = decodedPolylinePointsResult
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            visible: true,
            points: routePoints,
            width: 5,
            color: Colors.blue,
          ));
        });
        print("Polyline added with ${routePoints.length} points.");
      } else {
        print("No polyline points decoded.");
      }
    } else {
      print("Origin or destination point is null.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<LatLng>(
            future: locationFuture,
            builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _originPoint != null
                        ? LatLng(_originPoint!.latitude, _originPoint!.longitude)
                        : snapshot.data != null
                            ? LatLng(snapshot.data!.latitude, snapshot.data!.longitude)
                            : _initialPosition,
                    zoom: 14.4746,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                );
              }
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              child: TypeAheadField(
                suggestionsBoxVerticalOffset: 10.0,
                hideOnEmpty: true,
                hideOnLoading: true,
                hideSuggestionsOnKeyboardHide: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  if (pattern.length > 3) {
                    return searchPlaces(pattern);
                  } else {
                    return Future.value([]);
                  }
                },
                itemBuilder: (context, dynamic suggestion) {
                  if (suggestion is Place) {
                    return ListTile(
                      title: Text(suggestion.name),
                      subtitle: Text(suggestion.location.toString()),
                    );
                  } else {
                    return const ListTile(
                      title: Text('No results'),
                    );
                  }
                },
                onSuggestionSelected: (dynamic suggestion) {
                  if (suggestion is Place) {
                    animateCamera(suggestion.location);
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 110.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () async {
                Position position = await Geolocator.getCurrentPosition();
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(position.latitude, position.longitude),
                  ),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 40.0,
            left: 10.0,
            child: ElevatedButton(
              onPressed: () {
                if (_rideSnapshot != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: !_nextRide ? const Text('Ride Information') : const Text('Your next ride'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Driver: ${_rideSnapshot!['Driver']}'),
                            Text('Destination: ${_rideSnapshot!['Destination']}'),
                            Text('Origin: ${_rideSnapshot!['Origin']}'),
                            Text('Empty Seats: ${_rideSnapshot!['EmptySeats']}'),
                            Text('Time Left: ${getTimeLeft(_rideSnapshot!['EndTime'])}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No ride information available')),
                  );
                }
              },
              child: const Text('Info'),
            ),
          ),
        ],
      ),
    );
  }

  void animateCamera(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }
}
