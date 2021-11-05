import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:virtual_closet/screens/home/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


/*
* Stateless widget to give a summary of the user's calendar
 */
class CalendarSummary extends StatefulWidget {
  CalendarSummary({Key? key}) : super(key: key);

  @override
  _CalendarSummaryState createState() => _CalendarSummaryState();
} 

class _CalendarSummaryState extends State<CalendarSummary> {
  
  int numberOfTodayEvents = -1;
  List<Event>? listOfTodayEvents;
  String todaysEventsAsString = "";
  String displayAllEvents = "";
  final storage = new FlutterSecureStorage();
  DateFormat dateFormat = DateFormat("E, MMMM d");

  Future<void> doBlankCredentials()
  async {
    await storage.write(key: 'accessToken', value: '');
    await storage.write(key: 'refreshToken', value: '');
  }

  Future<void> getEvents()
  async {
    todaysEventsAsString = "";
    globals.numOfEvents = -1;
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

    /*
    clientViaUserConsent(_credentials, _scopes, prompt)
    .then((client) async {
      var calendar = CalendarApi(client);
      calEvents = calendar.events.list("primary");
    });*/
    //Comment out for now

    try 
    {
      clientViaUserConsent(_credentials, _scopes, prompt).then((AuthClient client) {
        var calendar = CalendarApi(client);

        DateTime start = DateTime.now().subtract( 
          Duration(
            hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().minute
          )
        );
        DateTime end = DateTime.now().add( 
          Duration(
            hours: 24 - DateTime.now().hour, minutes: 60 - DateTime.now().minute, seconds: 60 - DateTime.now().minute
          )
        );

        var calEvents = calendar.events.list("primary",
          timeMin: start,
          timeMax: end,
        );
        calEvents.then((Events events) {
          listOfTodayEvents = events.items!;
          for (var event in events.items!) 
          {
            EventDateTime? start = event.start;
            print(event.summary! + " " + start!.date.toString());
            todaysEventsAsString += event.summary! + "\n";
            globals.EVENTSOFTODAY += event.summary! + "\n";
          }
          print('access token: ' + client.credentials.accessToken.data);
          print('refresh token ' + client.credentials.refreshToken.toString());
          setTodayEvents(events.items!.length);
        });
      });
    } 
    catch (e) 
    {
      log('Error getting events $e');
    }
  }

  void setTodayEvents(int numberOfEvents)
  {
    setState(() {
        numberOfTodayEvents = numberOfEvents;
        displayAllEvents = todaysEventsAsString;
    });
  }

  void prompt(String url) async {
    if (await canLaunch(url)) {
      print(url);
      //await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Dialog getLeadDialog()
  {
    return Dialog(
    child: Container(
      height: 300.0,
      width: 360.0,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "${displayAllEvents}",
              style:
              TextStyle(color: Colors.black, fontSize: 18.0),
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                    child: FloatingActionButton(
                    onPressed: getEvents,
                    tooltip: 'New joke',
                    child: new Icon(Icons.refresh),
                  ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {

    if (numberOfTodayEvents == -1)
    {
      getEvents();
    }

    return InkWell(
        onTap: () {
          showDialog(builder: (BuildContext context) { return getLeadDialog(); }, context: context);
          },
        child: Container(
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
                listOfTodayEvents != null
                ? "Events Today: " + numberOfTodayEvents.toString()
                : "No events",
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ])),
      );
  }
}