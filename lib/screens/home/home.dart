import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:googleapis/spanner/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/account.dart';
import 'package:virtual_closet/screens/camera_screen/image_gallery.dart';
import 'package:virtual_closet/screens/closet/closet.dart';
import 'package:virtual_closet/screens/home/calendar.dart';
import 'package:virtual_closet/screens/home/item_swipe.dart';
import 'package:virtual_closet/screens/home/weather.dart';
import 'package:virtual_closet/screens/home/calendar.dart';
import 'package:virtual_closet/screens/home/notification_services.dart' as notifs;
import 'package:virtual_closet/screens/home/globals.dart' as globals;
import 'package:virtual_closet/screens/laundry/laundry.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'package:weather/weather.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.user})
      : super(key: key);

  final String title;
  final MyUser user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  int _selectedIndex = 0;
  HomeView homepage = const HomeView();

  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    Closet(),
    Laundry(),
    AccountPage()
  ];


  //Method to track index of tabs for the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Authentication _auth = Authentication(auth: FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Card(
            shape: RoundedRectangleBorder (borderRadius: BorderRadius.circular(10)),
            color: Colors.lightBlueAccent,
            child: FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('Logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      floatingActionButton: Container(
        height: 75,
        width: 75,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () => _onButtonPressed(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  tooltip: "Home",
                  icon: Icon(Icons.home, size: 35, color: _selectedIndex == 0 ? Colors.orange : Colors.black87),
                  onPressed: () {
                    _onItemTapped(0);
                  }),
              IconButton(
                  tooltip: "Closet",
                  icon: Icon(Icons.auto_awesome_mosaic, size: 35, color: _selectedIndex == 1 ? Colors.orange : Colors.black87),
                  onPressed: () {
                    _onItemTapped(1);
                  }),
              SizedBox(width: 40), //placeholder for FAB
              IconButton(
                  tooltip: "Laundry",
                  icon: Icon(Icons.auto_awesome, size: 35, color: _selectedIndex == 2 ? Colors.orange : Colors.black87),
                  onPressed: () {
                    _onItemTapped(2);
                  }),
              IconButton(
                  tooltip: "Account",
                  icon: Icon(Icons.account_circle, size: 35, color: _selectedIndex == 3 ? Colors.orange : Colors.black87),
                  onPressed: () {
                    _onItemTapped(3);
                  }),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 120,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Camera'),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ImageFromGalleryScreen('camera'))),
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_mosaic),
                  title: const Text('Gallery'),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ImageFromGalleryScreen('gallery'))),
                  },
                ),
              ],
            ),
          );
        });
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key,}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
    getWeatherInfo();
    getNotificationTime();
    getNotificationOnOff();
  }

  String weatherText = '';
  double? currTemp = 0.0;
  double? feelLike = 0.0;
  String weatherIconText = '';
  double currentLongitude = 0.0;
  double currentLatitude = 0.0;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isNotificatinOnOff = true;
  String actualIconCode = '';
  String top = '';
  String bottom = '';
  String shoes = '';


  Future<void> getNotificationTime()
  async {
    final prefs = await SharedPreferences.getInstance();
    final notificationHour = prefs.getInt('notificationHour') ?? 0;
    final notificationMinute = prefs.getInt('notificationMinute') ?? 0;

    if (notificationHour != 0 && notificationMinute != 0)
    {
      selectedTime = TimeOfDay(hour: notificationHour, minute: notificationMinute);
    }
  }

  Future<void> getNotificationOnOff()
  async {
    final prefs = await SharedPreferences.getInstance();
    final notificationOnoFF = prefs.getBool('notificationOnOff') ?? 0;

    if (notificationOnoFF == 0)
    {
      isNotificatinOnOff = false;
    }
    else
    {
      isNotificatinOnOff = notificationOnoFF as bool;
    }
  }


  // Method to call weather api and get current weather using latitude and longitude or city name etc.
  Future<void> getWeatherInfo() async {
    bool isServiceAvailable;
    LocationPermission permission;

    // Get api weather key from website and use with api weather factory
    String weatherAPIKey = "f7f16d98c61e6bf232846a3016491357";
    WeatherFactory wf =
    WeatherFactory(weatherAPIKey, language: Language.ENGLISH);

    // Check if location services is on
    isServiceAvailable = await Geolocator.isLocationServiceEnabled();
    if (!isServiceAvailable) {
      return Future.error(
          'Location services have been turned off, turn them on in the settings.');
    }

    // Check if location services on but disabled for this app
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Location permissions are not allowed for this app, turn it on in the settings');
      }
    }

    // Check if location services can be requested
    if (permission == LocationPermission.deniedForever) {
      return Future.error('App cannot request permissions.');
    }

    // If app can use current location get current lattitude and longitude to get weather for current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    // Set latitude and longitude
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
    Weather wlatlong =
    await wf.currentWeatherByLocation(currentLatitude, currentLongitude);

    // Change weather text to text from api weather call
    if (this.mounted)
    {
      setState(() {
      print(wlatlong.toString());
      currTemp = wlatlong.temperature!.fahrenheit;
      Temperature? tempFeel = wlatlong.tempFeelsLike;
      feelLike = tempFeel!.fahrenheit;
      String weatherDescription = wlatlong.weatherDescription!;
      String tempFeelLike = "\nFeels Like: " +
          tempFeel.fahrenheit!.toStringAsPrecision(3) +
          " Farenheit";
      weatherText = weatherDescription;
      actualIconCode = wlatlong.weatherIcon!;
      weatherIconText = transformWeatherIconText(wlatlong.weatherIcon!);
    });
    }
  }

  String transformWeatherIconText(String weatherIconText) {
    String commonScatteredClouds = 'wi-cloud';
    String commonBrokenClouds = 'wi-cloudy';
    String commonShowerRain = 'wi-rain';
    String commonThunderstorm = 'wi-thunderstorm';
    String commonSnow = 'wi-snow';
    String commonMist = 'wi-fog';

    if (weatherIconText == '01d') {
      weatherIconText = 'wi-day-sunny';
    } else if (weatherIconText == '02d') {
      weatherIconText = 'wi-day-cloudy-high';
    } else if (weatherIconText == '03d') {
      weatherIconText = commonScatteredClouds;
    } else if (weatherIconText == '04d') {
      weatherIconText = commonBrokenClouds;
    } else if (weatherIconText == '09d') {
      weatherIconText = commonShowerRain;
    } else if (weatherIconText == '10d') {
      weatherIconText = 'wi-day-rain';
    } else if (weatherIconText == '11d') {
      weatherIconText = commonThunderstorm;
    } else if (weatherIconText == '13d') {
      weatherIconText = commonSnow;
    } else if (weatherIconText == '50d') {
      weatherIconText = commonMist;
    }

    if (weatherIconText == '01n') {
      weatherIconText = 'wi-night-clear';
    } else if (weatherIconText == '02n') {
      weatherIconText = 'wi-night-cloudy';
    } else if (weatherIconText == '03n') {
      weatherIconText = commonScatteredClouds;
    } else if (weatherIconText == '04n') {
      weatherIconText = commonBrokenClouds;
    } else if (weatherIconText == '09n') {
      weatherIconText = commonShowerRain;
    } else if (weatherIconText == '10n') {
      weatherIconText = 'wi-night-rain';
    } else if (weatherIconText == '11n') {
      weatherIconText = commonThunderstorm;
    } else if (weatherIconText == '13n') {
      weatherIconText = commonSnow;
    } else if (weatherIconText == '50n') {
      weatherIconText = commonMist;
    }

    return weatherIconText;
  }

  String addIfNotThere(String addThis, String toThat)
  {
    for (int i = 0; i < toThat.length; i++)
    {
      if (addThis.matchAsPrefix(toThat, i) != null)
      {
        return toThat;
      }
    }
    return toThat += addThis;
  }

  // Helper function to translate weather icon code to weather code
  void weatherClothesFilter(String weatherIconText)
  {
    if (weatherIconText == '')
    {
      return;
    }

    if (weatherIconText == '01d') 
    {
      top = addIfNotThere("T-shirt", top);
      bottom = addIfNotThere("Shorts", bottom);
      shoes = addIfNotThere("open-toed-shoes", shoes);
    } 
    else if (weatherIconText == '02d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '03d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '04d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '09d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '10d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("boots", shoes);
    } 
    else if (weatherIconText == '11d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("boots", shoes);
    } 
    else if (weatherIconText == '13d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("boots", shoes);
    } 
    else if (weatherIconText == '50d') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toe-shoes", shoes);
    }

    if (weatherIconText == '01n') 
    {
      top = addIfNotThere("T-shirt", top);
      bottom = addIfNotThere("Shorts", bottom);
      shoes = addIfNotThere("open-toed-shoes", shoes);
    } 
    else if (weatherIconText == '02n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '03n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '04n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '09n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
    } 
    else if (weatherIconText == '10n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("boots", shoes);
    } 
    else if (weatherIconText == '11n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("boots", shoes);
    } 
    else if (weatherIconText == '13n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("boots", shoes);
    } 
    else if (weatherIconText == '50n') 
    {
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toe-shoes", shoes);
    }
  }

  void calendarClothesFilter()
  {
    // If key words in calendar events like "interview" or "lunch" then replace categories
    String events = globals.EVENTSOFTODAY;
    for (int i = 0; i < events.length; i++)
    {
      if ('interview'.matchAsPrefix(events.toLowerCase(), i) != null)
      {
        top = 'Suit';
        bottom = 'Pants';
        shoes = 'Shoes';
      }
      else if ('lunch'.matchAsPrefix(events.toLowerCase(), i) != null)
      {
        top = 'Shirts';
        bottom = 'Pants';
        shoes = 'shoes';
      }
      else if ('flight'.matchAsPrefix(events.toLowerCase(), i) != null)
      {
        top = 'T-shirt';
        bottom = 'Shorts';
        shoes = 'sneakers';
      }
    }
  }

  void timeClothesFilter(TimeOfDay currentTime, weatherIConCode)
  {
    if (weatherIConCode != '' || globals.EVENTSOFTODAY != '')
    {
      return;
    }
    // If user doesn't allow weather and has no google calendar hooked up then filter only using time
    if (currentTime.period.toString().substring(10, 12) == 'am')
    {
        top = addIfNotThere("T-shirt", top);
        bottom = addIfNotThere("Shorts", bottom);
        shoes = addIfNotThere("closed-toed-shoes", shoes);
        return;
    }
    if (currentTime.period.toString().substring(10, 12) == 'pm')
    {
        top = addIfNotThere("Shirts", top);
        bottom = addIfNotThere("Pants", bottom);
        shoes = addIfNotThere("closed-toed-shoes", shoes);
        return;
    }
  }

  int getRandomInt()
  {
    var randomGenerator = new Random();
    return randomGenerator.nextInt(50);
  }

  void getRecommendation()
  {
    // Get filters using helper functions
    weatherClothesFilter(actualIconCode);
    calendarClothesFilter();
    timeClothesFilter(TimeOfDay.now(), actualIconCode);
    //shoes = 'Shoes';

    // TODO get clothes from actual database with filtering
    var topOutfit = filterByItem(top);
    var bottomOutfit = filterByItem(bottom);
    var shoesOutfit = filterByItem(shoes);

    globals.item1 = "Item " + getRandomInt().toString() + " of " + top;
    globals.item2 = "Item " + getRandomInt().toString() + " of " + bottom;
    globals.item3 = "Item " + getRandomInt().toString() + " of " + shoes;
  }

  // Time picker widget
  selectTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final TimeOfDay? timeChosen = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeChosen != null && timeChosen != selectedTime)
    {
      setState(() {
        selectedTime = timeChosen;
      });
    }
    prefs.setInt('notificationHour', selectedTime.hour);
    prefs.setInt('notificationMinute', selectedTime.minute);
  }

  Future<void> setNotificationOnoFF(bool value)
  async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationOnOff', value);
    String currentDateTime = DateTime.now().toString();
    String userInputTime = (
      currentDateTime.substring(0, 11) + 
      selectedTime.hour.toString()) + ":" +
      selectedTime.minute.toString() + ":" +
      "00.000000"
    ;
    if (value == true)
    {
      //notifs.NotificationService().scheduleNotification(DateTime.parse(userInputTime), "message");
      print(DateTime.now().toString());
      print(userInputTime);
    }
  }


  @override
  Widget build(BuildContext context) {

    if (globals.recommendationOnOff == 0)
    {
      //getRecommendation();
      globals.recommendationOnOff = 1;
    }

    //placeholder, list of recommended items goes here
    List<ItemSwipe> items = [
      ItemSwipe(name: globals.item3),
      ItemSwipe(name: globals.item2),
      ItemSwipe(name: globals.item1),
    ];

    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: [ 
                    //call WeatherSummary and CalendarSummary here to display info
                    Flexible(
                      flex: 2,
                      child: WeatherSummary(
                        weatherText: weatherText,
                        currTemp: currTemp,
                        feelLike: feelLike,
                        weatherIconText: weatherIconText,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: CalendarSummary()
                    )
                  ],
                ),
                Container(
                    alignment: Alignment.center,
                    height: 400.0,
                    padding: EdgeInsets.only(left: 60.0),
                    child: Stack(
                      children: items,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        selectTime(context);
                      },
                      child: Text("Notification Time: " + selectedTime.hourOfPeriod.toString() + selectedTime.toString().substring(12, 15) + " " + selectedTime.period.toString().substring(10,12)),
                      ),
                    Switch(
                      value: isNotificatinOnOff,
                      onChanged: (value) {
                        setState(() {
                          setNotificationOnoFF(value);
                          isNotificatinOnOff = value;
                          getRecommendation();
                        });
                      }
                    ),
                  ],
                )
              ],
            )));
  }
}






