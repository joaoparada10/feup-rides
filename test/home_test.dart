import 'package:feup_rides/home.dart';
import 'package:feup_rides/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test setting myself available', (tester) async {
    await tester.pumpWidget(const HomePageBody());
    userType = 'driver';
    available = false; 

    await tester.tap(find.byType(Switch));

    expect(available, true);
  });

  testWidgets('Test setting myself unavailable', (tester) async {
    await tester.pumpWidget(const HomePageBody());

    userType = 'driver';
    available = false;

    await tester.tap(find.byType(Switch));
    await tester.tap(find.byType(Switch));

    expect(available, false);
  });
}