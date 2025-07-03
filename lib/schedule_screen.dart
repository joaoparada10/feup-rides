import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database/ride_fetching.dart';
import 'event.dart';
import 'utilities/place.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'home.dart';
import 'package:intl/intl.dart'; // Import this for DateFormat

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SchedulePage extends StatefulWidget {
  final String userUid;

  const SchedulePage({Key? key, required this.userUid}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late String _driverId;
  bool isDriver = false;
  Map<String, List<Ride>> events = {};
  TextEditingController _startPointController = TextEditingController();
  TextEditingController _endPointController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _numOfEmptySeatsController = TextEditingController();
  late final ValueNotifier<List<Ride>> _selectedEvents;

  TimeOfDay _selectedStartTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchUserRides(widget.userUid); // Fetch rides when the page is loaded
    _fetchIsDriver();
  }

  Future<void> _fetchIsDriver() async {
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(widget.userUid).get();

    setState(() {
      isDriver = userSnapshot.get('isDriver') as bool;
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
      _focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  List<Ride> _getEventsForDay(DateTime day) {
    return events[DateFormat('yyyy-MM-dd').format(day)] ?? [];
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedStartTime = pickedTime;
        _startTimeController.text = _selectedStartTime.format(context);
      });
    }
  }

  void _addEvent() async {
    if (_selectedDay != null &&
        _startPointController.text.isNotEmpty &&
        _endPointController.text.isNotEmpty &&
        _numOfEmptySeatsController.text.isNotEmpty &&
        _startTimeController.text.isNotEmpty) {
      final newEvent = Ride(
        origin: _startPointController.text,
        destination: _endPointController.text,
        emptySeats: int.parse(_numOfEmptySeatsController.text),
        startTime: DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          _selectedStartTime.hour,
          _selectedStartTime.minute,
        ),
        endTime: DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          _selectedStartTime.hour,
          _selectedStartTime.minute + 10,
        ),
      );

      setState(() {
        if (events
            .containsKey(DateFormat('yyyy-MM-dd').format(_selectedDay!))) {
          events[DateFormat('yyyy-MM-dd').format(_selectedDay!)]!.add(newEvent);
        } else {
          events[DateFormat('yyyy-MM-dd').format(_selectedDay!)] = [newEvent];
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay!);

            _startPointController.clear();
            _endPointController.clear();
            _startTimeController.clear();
            _numOfEmptySeatsController.clear();
          });
      createRideSchedule(newEvent, widget.userUid, context);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill in all fields')),
          );
        }
  }
      


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isDriver && DateTime.now().isBefore(_focusedDay.add(Duration(days: 1)))
        ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text("New Ride"),
                      content: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TypeAheadField(
                              suggestionsBoxVerticalOffset: 10.0,
                              hideOnEmpty: true,
                              hideOnLoading: true,
                              hideSuggestionsOnKeyboardHide: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _startPointController,
                                decoration: InputDecoration(
                                  labelText: 'Starting Point',
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
                                    subtitle:
                                        Text(suggestion.location.toString()),
                                  );
                                } else {
                                  return const ListTile(
                                    title: Text('No results'),
                                  );
                                }
                              },
                              onSuggestionSelected: (dynamic suggestion) {
                                if (suggestion is Place) {
                                  _startPointController.text = suggestion.name;
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            TypeAheadField(
                              suggestionsBoxVerticalOffset: 10.0,
                              hideOnEmpty: true,
                              hideOnLoading: true,
                              hideSuggestionsOnKeyboardHide: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _endPointController,
                                decoration: InputDecoration(
                                  labelText: 'Ending Point',
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
                                    subtitle:
                                        Text(suggestion.location.toString()),
                                  );
                                } else {
                                  return const ListTile(
                                    title: Text('No results'),
                                  );
                                }
                              },
                              onSuggestionSelected: (dynamic suggestion) {
                                if (suggestion is Place) {
                                  _endPointController.text = suggestion.name;
                                }
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _numOfEmptySeatsController,
                              decoration: InputDecoration(
                                  labelText: 'Number of empty seats'),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _startTimeController,
                              decoration:
                                  InputDecoration(labelText: 'Start Time'),
                              readOnly: true,
                              onTap: () => _showTimePicker(context),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: _addEvent,
                          child: Text("Submit"),
                        )
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            )
          : SizedBox(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(today.toString().split(" ")[0]),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0), // Adjust the value as per your requirement
                ),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2024, 4, 10),
                  lastDay: DateTime.utc(2030, 4, 10),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  availableGestures: AvailableGestures.all,
                  onDaySelected: _onDaySelected,
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    selectedTextStyle: TextStyle(color: Colors.white), // Text style of the selected date
                    defaultTextStyle: TextStyle(color: Colors.black), // Text style of other dates
                    weekendTextStyle: TextStyle(color: Colors.red), // Text style of weekend dates
                    outsideTextStyle: TextStyle(color: Colors.grey), // Text style of dates outside the current month
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                height: 300,
                child: ValueListenableBuilder<List<Ride>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if (value.isEmpty) {
                      return Center(
                        child: Text('No planned rides for this day'),
                      );
                    }

                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final event = value[index];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Ride Information'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('From: ${event.origin}'),
                                        Text('To: ${event.destination}'),
                                        Text(
                                            'Start Time: ${DateFormat('HH:mm').format(event.startTime)}'),
                                        Text(
                                            'End Time: ${DateFormat('HH:mm').format(event.endTime)}'),
                                      ],
                                    ),
                                    actions: [
                                      if (event.startTime
                                          .isAfter(DateTime.now()))
                                        ElevatedButton(
                                          onPressed: () {
                                            _cancelRide(event.startTime,
                                                widget.userUid);
                                          },
                                          child: Text('Cancel Ride'),
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                            title: Text(
                                'From ${event.origin} - ${event.destination} | ${event.emptySeats} seats available.'),
                            subtitle: Text(
                                'The car will be waiting at: ${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}\n'
                                'The car will leave at: ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchUserRides(String userId) async {
    try {
      QuerySnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('Rides')
          .where('DriverUid', isEqualTo: userId)
          .get();

      Map<String, List<Ride>> tempEvents = {};

      rideSnapshot.docs.forEach((doc) {
        Timestamp startTimeStamp = doc['StartTime'];
        Timestamp endTimeStamp = doc['EndTime'];

        Ride ride = Ride(
          origin: doc['Origin'],
          destination: doc['Destination'],
          emptySeats: doc['EmptySeats'],
          startTime: startTimeStamp.toDate(),
          endTime: endTimeStamp.toDate(),
        );

        String dayKey = DateFormat('yyyy-MM-dd').format(ride.startTime);
        if (tempEvents.containsKey(dayKey)) {
          tempEvents[dayKey]!.add(ride);
        } else {
          tempEvents[dayKey] = [ride];
        }
      });

      // Update the main events map
      setState(() {
        events.addAll(tempEvents);
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (error) {
      print("Failed to fetch user rides: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user rides')),
      );
    }
  }
  void _cancelRide(DateTime startTime, String driverId) async {
    try {
      QuerySnapshot rideSnapshot = await FirebaseFirestore.instance
          .collection('Rides')
          .where('DriverUid', isEqualTo: driverId)
          .where('StartTime', isEqualTo: startTime)
          .get();

      if (rideSnapshot.docs.isNotEmpty) {
        DocumentSnapshot rideDoc = rideSnapshot.docs.first;
        await rideDoc.reference.delete();
        _fetchUserRides(widget.userUid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The ride was canceled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No ride found to cancel')),
        );
      }
    } catch (error) {
      print("Failed to cancel ride: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel ride')),
      );
    }
  }
}