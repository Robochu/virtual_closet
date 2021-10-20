import 'package:flutter/material.dart';
import 'package:flutter_swipable/flutter_swipable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/account.dart';
import 'package:virtual_closet/screens/camera_screen/image_gallery.dart';
import 'package:virtual_closet/screens/closet/closet.dart';
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
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Closet(),
    Text(
      'Laundry',
      style: optionStyle,
    ),
    AccountPage()
  ];

  /*
  ListView(children: <Widget>[
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Text(
            'Account',
            style: optionStyle,
          )),
      Container(
        padding: EdgeInsets.all(10),
        child: Text(
          widget.user.displayName != null?,
        )
      ),
    ])

  static const List<List<Widget>> _tabOptions = <List<Widget>>[
    <Widget>[
      Text(
        'Home',
        style: optionStyle,
      ),
    ],
    <Widget>[
      Closet(),
    ],
    <Widget>[
      Text(
        'Laundry',
        style: optionStyle,
      ),
    ],
    <Widget>[
      Text(
        'Account',
        style: optionStyle,
      )
    ],
  ];*/

  //Method to track index of tabs for the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Authentication _auth = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('TEMP logout'),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
                  icon: Icon(Icons.home, size: 35),
                  onPressed: () {
                    _onItemTapped(0);
                    // When user clicks on homebutton a call to weather API is made and refreshes weather data
                    //getWeatherInfo();
                  }),
              IconButton(
                  tooltip: "Closet",
                  icon: Icon(Icons.auto_awesome_mosaic, size: 35),
                  onPressed: () {
                    _onItemTapped(1);
                  }),
              SizedBox(width: 40), //placeholder for FAB
              IconButton(
                  tooltip: "Laundry",
                  icon: Icon(Icons.auto_awesome, size: 35),
                  onPressed: () {
                    _onItemTapped(2);
                  }),
              IconButton(
                  tooltip: "Account",
                  icon: Icon(Icons.account_circle, size: 35),
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      currTemp = wlatlong.temperature!.fahrenheit;
      Temperature? tempFeel = wlatlong.tempFeelsLike;
      feelLike = tempFeel!.fahrenheit;
      String weatherDescription = wlatlong.weatherDescription!;
      String tempFeelLike = "\nFeels Like: " +
          tempFeel.fahrenheit!.toStringAsPrecision(3) +
          " Farenheit";
      weatherText = weatherDescription;
      weatherIconText = transformWeatherIconText(wlatlong.weatherIcon!);

      print(weatherText);
      print(weatherIconText);
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
    } else if (weatherIconText == '010d') {
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
    } else if (weatherIconText == '010n') {
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
            Flexible(
              flex: 2,
              child: WeatherSummary(
                weatherText: weatherText,
                currTemp: currTemp,
                feelLike: feelLike,
                weatherIconText: weatherIconText,
              ),
            ),
          ],
        ),
        Container(
            height: 400.0,
            padding: EdgeInsets.only(left: 50.0),
            child: Stack(
              children: items,
            ))
      ],
    )));
  }
}

class WeatherSummary extends StatelessWidget {
  final double? currTemp;
  final double? feelLike;
  final String weatherText;
  final String weatherIconText;

  const WeatherSummary(
      {Key? key,
      required this.weatherText,
      required this.currTemp,
      required this.feelLike,
      required this.weatherIconText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(15.0),
        color: Colors.blue,
        height: 70,
        width: 170,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(
            children: [
              Text(
                '${_formatTemperature(currTemp)}°F',
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
              Text(
                weatherText,
                style: const TextStyle(fontSize: 11),
              ),
              Text('Feel like ${_formatTemperature(feelLike)}°F',
                  style: const TextStyle(fontSize: 11))
            ],
          ),
          Icon(
              WeatherIcons.fromString(weatherIconText,
                  fallback: WeatherIcons.na),
              size: 40)
        ]));
  }

  String _formatTemperature(double? t) {
    var temp = (t == null ? '' : t.round().toString());
    return temp;
  }
}

class CalendarSummary extends StatelessWidget {
  const CalendarSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class ItemSwipe extends StatelessWidget {
  const ItemSwipe({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Swipable(
      child: Container(
        height: 350,
        width: 300,
        padding: EdgeInsets.only(top: 50.0),
        decoration: BoxDecoration(
        color: Colors.grey,),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
