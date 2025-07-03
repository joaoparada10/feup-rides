import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database/ride_fetching.dart';
import 'event.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'home.dart';
import 'package:intl/intl.dart';

import 'utilities/map_utilities.dart';  // Import this for DateFormat

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ScheduleSeerPage extends StatefulWidget {
  final String userUid;

  const ScheduleSeerPage({Key? key, required this.userUid}) : super(key: key);

  @override
  _ScheduleSeerPageState createState() => _ScheduleSeerPageState();
}

class _ScheduleSeerPageState extends State<ScheduleSeerPage> {
  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late String _driverId;
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
    _fetchUserRides(widget.userUid);  // Fetch rides when the page is loaded
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('From: ${event.origin}'),
                                        Text('To: ${event.destination}'),
                                        Text('Start Time: ${DateFormat('HH:mm').format(event.startTime)}'),
                                        Text('End Time: ${DateFormat('HH:mm').format(event.endTime)}'),
                                      ],
                                    ),
                                    actions: [

                                    ],
                                  );
                                },
                              );
                            },
                            title: Text('From ${event.origin} - ${event.destination} | ${event.emptySeats} seats available.'),
                            subtitle: Text(
                                'The car will be waiting at: ${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}\n'
                                    'The car will leave at: ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}'
                            ),
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
      QuerySnapshot rideSnapshot = await FirebaseFirestore.instance.collection('Rides').where('DriverUid', isEqualTo: userId).get();

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
  }
