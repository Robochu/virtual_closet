import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart' hide Colors;
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
  String todaysEventsAsString = "";
  String displayAllEvents = "Please Connect Your Calendar";
  final storage = new FlutterSecureStorage();
  DateFormat dateFormat = DateFormat("E, MMMM d");

  Future<void> writeCredentials(String atd, String att, String ate, String rt)
    async {
      await storage.write(key: 'accessTokenData', value: atd);
      await storage.write(key: 'accessTokenType', value: att);
      await storage.write(key: 'accessTokenExpiry', value: ate);
      await storage.write(key: 'refreshToken', value: rt);
  }

  String getAccessTokenData()
  {
    var at = storage.read(key: 'accessTokenData') ?? "";

    return at.toString();
  }
  String getAccessTokenType()
  {
    var at = storage.read(key: 'accessTokenType') ?? "";

    return at.toString();
  }
  String getAccessTokenExpiry()
  {
    var at = storage.read(key: 'accessTokenExpiry') ?? "";

    return at.toString();
  }
  String getRefreshToken()
  {
    var rt = storage.read(key: 'refreshToken') ?? "";

    return rt.toString();
  }

  Future<void> getEvents()
  async {
    todaysEventsAsString = "";
    globals.numOfEvents = -1;
    var accessTokenFromStorage;
    var atd = await getAccessTokenData();
    var att = await getAccessTokenType();
    var ate = await getAccessTokenExpiry();
    var rt = await getRefreshToken();
    
    var _scopes = [CalendarApi.calendarEventsReadonlyScope];
    
    var _credentials;
    if (atd != "" && rt != "")
    {
      accessTokenFromStorage = AccessToken.fromJson(
        {
          'type': att,
          'data': atd,
          'expiry': ate
        }
      );
    }
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
          print(client.credentials.accessToken.toJson());
          //writeCredentials(client.credentials.accessToken.data, client.credentials.accessToken.type, client.credentials.accessToken.expiry.toString(), client.credentials.refreshToken.toString());
          //prefs.setString('accessToken', client.credentials.accessToken);
          //prefs.setString('refreshToken', client.credentials.refreshToken.toString());
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
        if (todaysEventsAsString == "")
        {
          displayAllEvents = "No Events to Display";
        }
        else
        {
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

  Dialog getCalendarDialog()
  {
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
            color: Colors.black
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              displayAllEvents,
              style:
              const TextStyle(color: Colors.black, fontSize: 18.0),
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, right: 7.5),
                    child: FloatingActionButton(
                    onPressed: getEvents,
                    tooltip: 'New joke',
                    child: Icon(Icons.refresh),
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

    if (numberOfTodayEvents == -2)
    {
      getEvents();
    }

    return InkWell(
        onTap: () {
          showDialog(builder: (BuildContext context) { return getCalendarDialog(); }, context: context);
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
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ])),
      );
  }
}