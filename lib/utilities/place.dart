import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Place {
  final String name;
  final LatLng location;

  Place({required this.name, required this.location});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      location: LatLng(
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
      ),
    );
  }
}

Future<List<Place>> searchPlaces(String searchTerm) async {
  final response = await http.get(
    Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$searchTerm&key='),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
      return data['results'].map<Place>((item) => Place.fromJson(item)).toList();
    } else {
      throw Exception('No results found for the provided search term');
    }
  } else {
    throw Exception('Failed to load places');
  }
}