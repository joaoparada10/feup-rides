import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'utilities/map_utilities.dart';
import 'utilities/place.dart';
import 'utilities/date_time_utilities.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'map_page.dart';
import 'profile_page.dart';
import 'schedule_seer.dart';

bool available = false;

class MyHomePage extends StatefulWidget {
  final String userUid;
  const MyHomePage({Key? key, required this.userUid}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
    _pages = <Widget>[
      HomePageBody(userUid: widget.userUid),
      MapPage(userUid: widget.userUid),
      UserProfilePage(userUid: widget.userUid),
    ];
  }

  void _initFirebaseMessaging() {
    FirebaseMessaging.instance.getToken().then((token) {
      print('FCM Token: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message data: ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message data: ${message.data}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FEUP RIDES', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF9A3324),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageBody extends StatefulWidget {
  final String userUid;

  const HomePageBody({super.key, required this.userUid});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  bool isDriver = false;

  void initState() {
    super.initState();
    _fetchIsDriver();
  }

  Future<void> _fetchIsDriver() async {
    final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userUid)
        .get();

    setState(() {
      isDriver = userSnapshot.get('isDriver') as bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Rides').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final rides = snapshot.data!.docs;
        final futureRides = rides.where((ride) {
          final rideData = ride.data() as Map<String, dynamic>;
          final endTimestamp = rideData['EndTime'] as Timestamp;
          return endTimestamp.toDate().isAfter(DateTime.now());
        }).toList();
        futureRides.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aEndTime = (aData['EndTime'] as Timestamp).toDate();
        final bEndTime = (bData['EndTime'] as Timestamp).toDate();
        return aEndTime.compareTo(bEndTime);
      });
        

        return Column(
          children: [
            if (futureRides.isEmpty) 
              const Expanded(child: Center (child:Text('No rides available')))
            else 
            Expanded(
              child: ListView.builder(
                itemCount: futureRides.length,
                itemBuilder: (context, index) {
                  final rideDoc = futureRides[index];
                  final ride =
                      futureRides[index].data() as Map<String, dynamic>;
                  final rideId = futureRides[index].id;
                  final origin = ride['Origin'] ?? '';
                  final destination = ride['Destination'] ?? '';
                  final originPoint =
                      getAddress(ride['OriginPoint'] ?? const GeoPoint(0, 0));
                  final destinationPoint =
                      getAddress(ride['DestinationPoint'] ?? const GeoPoint(0, 0));
                  final driver = ride['Driver'] ?? '';
                  final driverUid = ride['DriverUid'] ?? '';
                  Timestamp endTimestamp = ride['EndTime'] ?? '';
                  final formattedTimestamp = formatTimestamp(endTimestamp);
                  final emptySeats = ride['EmptySeats'] ?? 0;
                  final passengers =
                      List<String>.from(ride['Passengers'] ?? []);
                  return FutureBuilder(
                    future: Future.wait([originPoint, destinationPoint]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: ListTile(
                            title: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapPage(
                                      userUid: widget.userUid,
                                      rideSnapshot: rideDoc,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'From $origin to $destination',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            subtitle: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleSeerPage(userUid: driverUid),
                            ),
                          );
                        },
                        child: Text(
                          'Leaving at: $formattedTimestamp \n $driver \n Empty Seats: $emptySeats',
                          style: TextStyle(color: Color.fromARGB(255, 154, 51, 36)),
                        ),
                      ),
                            trailing: emptySeats > 0
                                ? (driverUid == widget.userUid
                                    ? ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('Rides')
                                              .doc(rideId)
                                              .delete();
                                        },
                                        child: const Text('Cancel Ride'),
                                      )
                                    : passengers.contains(widget.userUid)
                                        ? ElevatedButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('Rides')
                                                  .doc(rideId)
                                                  .update({
                                                'Passengers':
                                                    FieldValue.arrayRemove(
                                                        [widget.userUid]),
                                                'EmptySeats':
                                                    FieldValue.increment(1)
                                              });
                                            },
                                            child: const Text('Leave Ride'),
                                          )
                                        : ElevatedButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('Rides')
                                                  .doc(rideId)
                                                  .update({
                                                'Passengers':
                                                    FieldValue.arrayUnion(
                                                        [widget.userUid]),
                                                'EmptySeats':
                                                    FieldValue.increment(-1)
                                              });
                                            },
                                            child: const Text('Join Ride'),
                                          ))
                                : null,
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  );
                },
              ),
            ),
            isDriver
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateRidePage(userUid: widget.userUid)),
                        );
                      },
                      child: const Text('Start New Ride'),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }
}


class CreateRidePage extends StatefulWidget {
  final String userUid;
  const CreateRidePage({Key? key, required this.userUid}) : super(key: key);
  @override
  _CreateRidePageState createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _emptySeatsController = TextEditingController();
  late GeoPoint _originPoint;
  late GeoPoint _destinationPoint;
  bool useCarseats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ride'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeAheadFormField('Origin', _originController, (suggestion) {
                    if (suggestion is Place) {
                      _originController.text = suggestion.name;
                      _originPoint = GeoPoint(suggestion.location.latitude, suggestion.location.longitude);
                    }
                  }),
                  const SizedBox(height: 20),
                  _buildTypeAheadFormField('Destination', _destinationController, (suggestion) {
                    if (suggestion is Place) {
                      _destinationController.text = suggestion.name;
                      _destinationPoint = GeoPoint(suggestion.location.latitude, suggestion.location.longitude);
                    }
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: useCarseats,
                        onChanged: (bool? value) {
                          setState(() {
                            useCarseats = value ?? true;
                            if (useCarseats) {
                              _emptySeatsController.clear();
                            }
                          });
                        },
                      ),
                      const Text('Use current car seats', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emptySeatsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Empty Seats',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: !useCarseats,
                    validator: (value) {
                      if ((value == null || value.isEmpty) && !useCarseats) {
                        return 'Please enter the number of empty seats';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _createRide();
                        }
                      },
                      child: const Text('Create Ride'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAheadFormField(String label, TextEditingController controller, Function(dynamic) onSuggestionSelected) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
      onSuggestionSelected: onSuggestionSelected,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $label';
        }
        return null;
      },
    );
  }

  Future<void> _createRide() async {
    Timestamp startTime = Timestamp.now();
    DateTime startDateTime = startTime.toDate();
    DateTime endDateTime = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
      startDateTime.hour,
      startDateTime.minute + 10,
    );
    Timestamp endTime = Timestamp.fromDate(endDateTime);
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userUid)
        .get();
    String firstName = userSnapshot['firstName'] ?? '';
    String lastName = userSnapshot['lastName'] ?? '';
    String driverName = '$firstName $lastName';
    int carSeats = 0;
    QuerySnapshot carSnapshot = await FirebaseFirestore.instance
        .collection('cars')
        .where('driverUid', isEqualTo: widget.userUid)
        .where('active', isEqualTo: 1)
        .limit(1)
        .get();

    if (carSnapshot.docs.isNotEmpty) {
      // Retrieve the car document
      DocumentSnapshot carDoc = carSnapshot.docs.first;
      carSeats = carDoc['seats'];
    }

    String origin = _originController.text;
    String destination = _destinationController.text;
    GeoPoint originPoint = _originPoint;
    GeoPoint destinationPoint = _destinationPoint;

    final rideData = {
      'OriginPoint': originPoint,
      'DestinationPoint': destinationPoint,
      'Origin': origin,
      'Destination': destination,
      'Driver': driverName,
      'DriverUid': widget.userUid,
      'EmptySeats':
          _emptySeatsController.text.isEmpty ? carSeats : int.parse(_emptySeatsController.text),
      'EndTime': endTime,
      'StartTime': startTime,
    };

    FirebaseFirestore.instance.collection('Rides').add(rideData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride created successfully')));
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to create ride: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to create ride')));
    });
  }
}
