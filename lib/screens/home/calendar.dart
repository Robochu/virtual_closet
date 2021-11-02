import 'dart:io';
import 'package:flutter/material.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';


/*
* Stateless widget to give a summary of the user's calendar
 */
class CalendarSummary extends StatelessWidget {
  const CalendarSummary({Key? key}) : super(key: key);

  void getEvents()
  {
    var _scopes = [CalendarApi.calendarEventsReadonlyScope];
    var _credentials;

    if (Platform.isAndroid) {
      _credentials = ClientId(
          "154107775948-4remimlnem5cfdmgsb8rchrsfb7tm7am.apps.googleusercontent.com",
          "");
    } 
    else if (Platform.isIOS) {
      _credentials = ClientId(
          "154107775948-ps9jbbrsv56gc7qcrr7fansaa7botlp9.apps.googleusercontent.com",
          "");
    }

    clientViaServiceAccount(_credentials, _scopes).then((client) {
      var calendar = CalendarApi(client);
      var calEvents = calendar.events.list("primary");
      calEvents.then((Events events) {
        for (var event in events.items!) 
        {
          print(event.summary);
        }
      });
    });

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}