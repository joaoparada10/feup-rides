import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CarPage extends StatefulWidget {
  final String userUid;

  const CarPage({Key? key, required this.userUid}) : super(key: key);

  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  late String selectedCar;
  late String activeCar;
  final Map<String, CarData> carDataMap = {
    'Car 1': CarData(),
    'Car 2': CarData(),
  };

  @override
  void initState() {
    super.initState();
    selectedCar = 'Car 1';
    activeCar = selectedCar;
    fetchCarInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Car'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _carButton('Car 1'),
                _carButton('Car 2'),
              ],
            ),
            SizedBox(height: 20),
            if (selectedCar.isNotEmpty) ...[
              Center(
                child: Text('Enter Details for $selectedCar'),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 385),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Car Model',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                          controller: carDataMap[selectedCar]!.carModelController,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Car Year',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                          controller: carDataMap[selectedCar]!.carYearController,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Car Plate',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                          controller: carDataMap[selectedCar]!.carPlateController,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Empty Seats',
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(color: Colors.black),
                          controller: carDataMap[selectedCar]!.EmptySeatsController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Upload Car Pictures (up to 3)'),
              IconButton(onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                XFile? file =
                await imagePicker.pickImage(source: ImageSource.gallery);
                Reference rootReference = FirebaseStorage.instance.ref();
                Reference carImageRef;
              }, icon: Icon(Icons.camera_alt)),
              Spacer(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setActiveCar(selectedCar);
                    },
                    child: Text('Set Active'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      clearCarData(selectedCar);
                    },
                    child: Text('Clear Car Data'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  saveCarDetailsToFirestore(selectedCar, widget.userUid);
                },
                child: Text('Save'),
              ),
              SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _carButton(String carName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCar = carName;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedCar == carName ? Colors.white : null,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Text(
              carName,
              style: TextStyle(
                color: selectedCar == carName ? Colors.black : null,
              ),
            ),
            if (activeCar == carName)
              Icon(Icons.star, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  void saveCarDetailsToFirestore(String selectedCar, String UserUid) async {
    try {
      String carModel = carDataMap[selectedCar]!.carModelController.text;
      String carYear = carDataMap[selectedCar]!.carYearController.text;
      String carPlate = carDataMap[selectedCar]!.carPlateController.text;
      int emptySeats = int.parse(carDataMap[selectedCar]!.EmptySeatsController.text);

      CollectionReference carsCollection = FirebaseFirestore.instance.collection('cars');

      await carsCollection.add({
        'model': carModel,
        'year': carYear,
        'plate': carPlate,
        'car': selectedCar,
        'driverUid': UserUid,
        'seats': emptySeats,
        'active': 0,
      });

      print('Car details for $selectedCar saved successfully!');
    } catch (e) {
      print('Error saving car details: $e');
    }
  }

  Future<void> fetchCarInfo() async {
    try {
      final carSnapshot = await FirebaseFirestore.instance
          .collection('cars')
          .where('driverUid', isEqualTo: widget.userUid)
          .get();

      for (var doc in carSnapshot.docs) {
        final carData = doc.data();
        final carName = carData['car'];

        if (carDataMap.containsKey(carName)) {
          setState(() {
            carDataMap[carName]!.carModelController.text = carData['model'];
            carDataMap[carName]!.carYearController.text = carData['year'];
            carDataMap[carName]!.carPlateController.text = carData['plate'];
            carDataMap[carName]!.EmptySeatsController.text = carData['seats'].toString();
          });
        }
      }
    } catch (e) {
      print('Error fetching car information: $e');
    }
  }

  void setActiveCar(String carName) async {
    setState(() {
      activeCar = carName;
    });

    try {
      final carsCollection = FirebaseFirestore.instance.collection('cars');

      final userCarsSnapshot = await carsCollection
          .where('driverUid', isEqualTo: widget.userUid)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in userCarsSnapshot.docs) {
        final car = doc.data();
        final carDocRef = doc.reference;
        if (car['car'] == carName) {
          batch.update(carDocRef, {'active': 1});
        } else {
          batch.update(carDocRef, {'active': 0});
        }
      }

      await batch.commit();

      print('Set $carName as active car successfully!');
    } catch (e) {
      print('Error setting active car: $e');
    }
  }

  void clearCarData(String carName) async {
    setState(() {
      carDataMap[carName]!.carModelController.clear();
      carDataMap[carName]!.carYearController.clear();
      carDataMap[carName]!.carPlateController.clear();
      carDataMap[carName]!.EmptySeatsController.clear();
    });

    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .where('driverUid', isEqualTo: widget.userUid)
          .where('car', isEqualTo: carName)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      print('Data for $carName cleared successfully!');
    } catch (e) {
      print('Error clearing car data: $e');
    }
  }
}

class CarData {
  TextEditingController carModelController = TextEditingController();
  TextEditingController carYearController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();
  TextEditingController EmptySeatsController = TextEditingController();
}
