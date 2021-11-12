// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:virtual_closet/main.dart';
import 'package:virtual_closet/account/account.dart';
final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'testing.unit@gmail.com',
  displayName: 'UnitTest',
);

void main() {
  testWidgets('shows user info', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('user').doc(tUser.uid).set({
      'name': 'Unit',
      'lastName': 'Test',
      'uid': tUser.uid,
      'email': tUser.email,
      'dob': '11/03/2021'
    });

    //Render the widget
  });
}
