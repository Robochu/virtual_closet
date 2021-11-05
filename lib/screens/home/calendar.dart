import 'dart:io';
import 'package:flutter/material.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


/*
* Stateless widget to give a summary of the user's calendar
 */

class CalendarSummary extends StatelessWidget {
  CalendarSummary({Key? key, }) : super(key: key);
  final DateFormat dateFormat = DateFormat("E, MMMM d");
  var calEvents;


  void getEvents()
  {
    var _scopes = [CalendarApi.calendarScope];
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
/*
    clientViaUserConsent(_credentials, _scopes, prompt)
    .then((client) async {
      var calendar = CalendarApi(client);
      calEvents = calendar.events.list("primary");
    });*/
    //Comment out for now

    clientViaServiceAccount(_credentials, _scopes).then((client) {
      var calendar = CalendarApi(client);
      calEvents = calendar.events.list("primary");
      calEvents.then((Events events) {
        for (var event in events.items!) 
        {
          print(event.summary);
        }
      });
    });

  }
  /*
    void prompt(String url) async {
      if (await canLaunch(url)) {
        print("Have url");
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }*/



  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            )),
        height: 70,
        width: 170,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateFormat.format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,

                ),
              ),
              Text(
                calEvents != null
                ? calEvents.join("\n")
                : "No events",
                style: const TextStyle(fontSize: 20),
              ),

            ],
          ),
        ]));
  }
}