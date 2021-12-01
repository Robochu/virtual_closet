
import 'dart:io';
import 'package:flutter/material.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:http/src/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_closet/screens/home/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/*
* Stateless widget to give a summary of the user's calendar
 */
class CalendarSummary extends StatefulWidget {
  const CalendarSummary({Key? key}) : super(key: key);

  @override
  _CalendarSummaryState createState() => _CalendarSummaryState();
}

class _CalendarSummaryState extends State<CalendarSummary> {
  int numberOfTodayEvents = globals.numOfEvents;
  List<Event>? listOfTodayEvents;
  String displayAllEvents =
      "Please connect your calendar, use the refresh button below to prompt the connect screen.";
  var calendar;

  DateFormat dateFormat = DateFormat("E, MMMM d");

  Future<void> writeCredentials(
      String atd, String att, String ate, String rt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessTokenData', atd);
    await prefs.setString('accessTokenType', att);
    await prefs.setString('accessTokenExpiry', ate);
    await prefs.setString('refreshToken', rt);
  }

  @override
  void initState() {
    super.initState();
    connectCalendar();
  }

  Future<void> connectCalendar() async {
    AccessToken accessTokenFromStorage;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var atd = prefs.getString('accessTokenData') ?? "";
    var att = prefs.getString('accessTokenType') ?? "";
    var ate = prefs.getString('accessTokenExpiry') ?? "";
    var rt = prefs.getString('refreshToken') ?? "";

    var _scopes = [CalendarApi.calendarEventsReadonlyScope];

    var _credentials;
    if (Platform.isAndroid) {
      _credentials = ClientId(
          "154107775948-4remimlnem5cfdmgsb8rchrsfb7tm7am.apps.googleusercontent.com",
          "");
    } else if (Platform.isIOS) {
      _credentials = ClientId(
          "154107775948-ps9jbbrsv56gc7qcrr7fansaa7botlp9.apps.googleusercontent.com",
          "");
    }

    if (atd != "" && rt != "" && ate != "") {
      //print("atd: $atd, rt: $rt");
      accessTokenFromStorage =
          AccessToken.fromJson({'type': att, 'data': atd, 'expiry': ate});

      AccessCredentials creds = await refreshCredentials(_credentials,
          AccessCredentials(accessTokenFromStorage, rt, _scopes), Client());
      Client client = Client();
      AuthClient authClient = autoRefreshingClient(_credentials, creds, client);
      calendar = CalendarApi(authClient);
    } else {
      clientViaUserConsent(_credentials, _scopes, prompt)
          .then((AuthClient client) {
        calendar = CalendarApi(client);
        writeCredentials(
            client.credentials.accessToken.data,
            client.credentials.accessToken.type,
            client.credentials.accessToken.expiry.toString(),
            client.credentials.refreshToken.toString());
      });
    }
    getEvents();
  }


  Future<void> getEvents() async {
    String todaysEventsAsString = "";
    globals.numOfEvents = -1;

    DateTime start = DateTime.now().subtract(Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().minute));
    DateTime end = DateTime.now().add(Duration(
        hours: 24 - DateTime.now().hour,
        minutes: 60 - DateTime.now().minute,
        seconds: 60 - DateTime.now().minute));

    var calEvents = calendar.events.list(
      "primary",
      timeMin: start,
      timeMax: end,
    );
    calEvents.then((Events events) {
      listOfTodayEvents = events.items!;
      for (var event in events.items!) {
        EventDateTime? start = event.start;
        EventDateTime? end = event.end;
        //print(event.summary! + " " + DateFormat.jm().format(start!.dateTime!));
        todaysEventsAsString += event.summary! +
            " " +
            DateFormat.jm().format(start!.dateTime!.toLocal()) +
            "-" +
            DateFormat.jm().format(end!.dateTime!.toLocal()) +
            "\n";
        globals.EVENTSOFTODAY += event.summary! + "\n";
      }


      setTodayEvents(events.items!.length, todaysEventsAsString);
    });
  }

  void setTodayEvents(int numberOfEvents, String todaysEventsAsString) {
    setState(() {
      numberOfTodayEvents = numberOfEvents;
      if (todaysEventsAsString == "") {
        displayAllEvents = "No Events to Display";
      } else {
        displayAllEvents = todaysEventsAsString;
      }
    });
  }

  void prompt(String url) async {
    if (await canLaunch(url)) {
      print(url);
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Dialog getCalendarDialog(setStateIn) {
    return Dialog(
      child: Container(
        height: 300.0,
        width: 360.0,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Today's Events",
              style: TextStyle(fontSize: 22),
            ),
            const Divider(
                thickness: 3.5,
                indent: 7.5,
                endIndent: 7.5,
                color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                displayAllEvents,
                style: const TextStyle(color: Colors.black, fontSize: 18.0),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, right: 7.5),
                  child: FloatingActionButton(
                    onPressed: () async {
                      displayAllEvents ==
                          "Please connect your calendar, use the refresh button below to prompt the connect screen."
                          ? await connectCalendar()
                          : await getEvents();

                      setStateIn(() {});
                    },
                    tooltip: 'New joke',
                    child: const Icon(Icons.refresh),
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
    if (numberOfTodayEvents == -2 && calendar != null) {
      getEvents();
    }


    return InkWell(
      onTap: () {
        showDialog(
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setStateIn) {
                return getCalendarDialog(setStateIn);
              });
            },
            context: context);
      },
      child: Container(
          margin: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 1,
              )),
          height: 70,
          width: 170,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ])),
    );
  }
}
