
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

Future<String> getRoute(GeoPoint origin, GeoPoint destination) async {
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key='));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final route = data['routes'][0]['overview_polyline']['points'];

    return route;
  } else {
    throw Exception('Failed to load route');
  }
}

Future<GeoPoint> getGeoPoint(String address) async {
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key='));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
      final lat = data['results'][0]['geometry']['location']['lat'];
      final lng = data['results'][0]['geometry']['location']['lng'];
      return GeoPoint(lat, lng);
    } else {
      throw Exception('No results found for the provided address');
    }
  } else {
    throw Exception('Failed to load geopoint');
  }
}

Future<String> getAddress(GeoPoint point) async {
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key='));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final address = data['results'][0]['formatted_address'];

    return address;
  } else {
    throw Exception('Failed to load address');
  }
}