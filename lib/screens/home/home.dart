import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/account.dart';
import 'package:virtual_closet/screens/camera_screen/image_gallery.dart';
import 'package:virtual_closet/screens/closet/closet.dart';
import 'package:virtual_closet/screens/home/calendar.dart';
import 'package:virtual_closet/screens/home/item_swipe.dart';
import 'package:virtual_closet/screens/home/weather.dart';
import 'package:virtual_closet/screens/laundry/laundry.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

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
                    // When user clicks on homebutton a call to weather API is made and refreshes weather data
                    //_HomeViewState().getWeatherInfo();
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
  }

  String weatherText = '';
  double? currTemp = 0.0;
  double? feelLike = 0.0;
  String weatherIconText = '';
  double currentLongitude = 0.0;
  double currentLatitude = 0.0;
  TimeOfDay selectedTime = TimeOfDay.now();


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
      weatherIconText = transformWeatherIconText(wlatlong.weatherIcon!);
    });
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

  // Helper function to translate weather icon code to weather code
  String weatherClothesFilter(String weatherIconText)
  {
    String filterCategories = '';

    if (weatherIconText == '01d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '02d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '03d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '04d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '09d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '10d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '11d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '13d') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '50d') {
      // Filter clothes based on this weather code
    }

    if (weatherIconText == '01n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '02n'){
      // Filter clothes based on this weather code
    } else if (weatherIconText == '03n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '04n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '09n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '10n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '11n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '13n') {
      // Filter clothes based on this weather code
    } else if (weatherIconText == '50n') {
      // Filter clothes based on this weather code
    }
    return filterCategories;
  }

  String calendarClothesFilter()
  {
    String filterCategories = '';
    // If key words in calendar events like "interview" or "lunch" then filter categories
    return filterCategories;
  }

  String onlyTimeClothesFilter(TimeOfDay currentTime)
  {
    String filterCategories = '';
    // If user doesn't allow weather and has no google calendar hooked up then filter only using time
    return filterCategories;
  }

  void getRecommendation()
  {
    // Get filters using helper functions
    String weatherFilter = weatherClothesFilter(weatherIconText);
    String calendarFilter = calendarClothesFilter();
    String timeFilter = onlyTimeClothesFilter(TimeOfDay.now());

    // If weather not allowed by user but caledar exists then use calendar and time
    if (weatherFilter == '' && calendarFilter != '')
    {
      getClothesBasedOnFilters(calendarFilter + timeFilter);
    }
    // If weather allowed by user but caledar is not then use only weatherFilter
    if (weatherFilter == '' && calendarFilter != '')
    {
      getClothesBasedOnFilters(weatherFilter);
    }
    // If weather and calendar not used/allowed by user then use only time filter
    if (weatherFilter != '' && calendarFilter != '')
    {
      getClothesBasedOnFilters(timeFilter);
    }
  }

  void getClothesBasedOnFilters(String filters)
  {
    // Filter closet based on input filters
    // Get clothes using chance system (with multipliers for liked pieces of clothing)
    // Assign clothes to the proper widget in the outfit widget
  }

  // Time picker widget
  selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null && timeOfDay != selectedTime)
    {
      setState(() {
        selectedTime = timeOfDay;
      });
    }
  }


 //placeholder, list of recommended items goes here
  List<ItemSwipe> items = [
    ItemSwipe(name: "Item1"),
    ItemSwipe(name: "Item2"),
    ItemSwipe(name: "Item3"),
  ];

  @override
  Widget build(BuildContext context) {
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
                ElevatedButton(
                    onPressed: () {
                      selectTime(context);
                    },
                    child: const Text("Choose Notification Time"),
                    ),
                    Text("${selectedTime.hourOfPeriod}:${selectedTime.minute} ${selectedTime.period.toString().substring(10,12)}"),
              ],
            )));
  }
}






