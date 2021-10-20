import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/account.dart';
import 'package:virtual_closet/screens/camera_screen/image_gallery.dart';
import 'package:virtual_closet/screens/closet/closet.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'package:weather/weather.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.user}) : super(key: key);

  final String title;
  final MyUser user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    getWeatherInfo();
  }

  int _selectedIndex = 0;
  String weatherText = '';
  String weatherIconText = '';
  double currentLongitude = 0.0;
  double currentLatitude = 0.0;

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
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

  // Method to call weather api and get current weather using latitude and longitude or city name etc.
  Future<void> getWeatherInfo() async {
    bool isServiceAvailable;
    LocationPermission permission;

    // Get api weather key from website and use with api weather factory
    String weatherAPIKey = "f7f16d98c61e6bf232846a3016491357";
    WeatherFactory wf = WeatherFactory(weatherAPIKey, language: Language.ENGLISH);

    // Check if location services is on
    isServiceAvailable = await Geolocator.isLocationServiceEnabled();
    if (!isServiceAvailable)
    {
      return Future.error('Location services have been turned off, turn them on in the settings.');
    }

    // Check if location services on but disabled for this app
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
    {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
      {
        return Future.error('Location permissions are not allowed for this app, turn it on in the settings');
      }
    }

    // Check if location services can be requested
    if (permission == LocationPermission.deniedForever)
    {
      return Future.error('App cannot request permissions.');
    }

    // If app can use current location get current lattitude and longitude to get weather for current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    // Set lattitude and longitude
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
    Weather wlatlong =
    await wf.currentWeatherByLocation(currentLatitude, currentLongitude);

    // Change weather text to text from api weather call
    setState(() {
      Temperature? tempFeel = wlatlong.tempFeelsLike;
      String weatherDescription = "Weather: " + wlatlong.weatherDescription!;
      String tempFeelLike = "\nFeels Like: "  + tempFeel!.fahrenheit!.toStringAsPrecision(3) + " Farenheit";
      weatherText = weatherDescription + tempFeelLike;
      weatherIconText = transformWeatherIconText(wlatlong.weatherIcon!);

      print(weatherText);
      print(weatherIconText);
    });
  }

  String transformWeatherIconText(String weatherIconText)
  {
    String commonScatteredClouds = 'wi-cloud';
    String commonBrokenClouds = 'wi-cloudy';
    String commonShowerRain = 'wi-rain';
    String commonThunderstorm = 'wi-thunderstorm';
    String commonSnow = 'wi-snow';
    String commonMist = 'wi-fog';

    if (weatherIconText == '01d')
    {
      weatherIconText = 'wi-day-sunny';
    }
    else if (weatherIconText == '02d')
    {
      weatherIconText = 'wi-day-cloudy-high';
    }
    else if (weatherIconText == '03d')
    {
      weatherIconText = commonScatteredClouds;
    }
    else if (weatherIconText == '04d')
    {
      weatherIconText = commonBrokenClouds;
    }
    else if (weatherIconText == '09d')
    {
      weatherIconText = commonShowerRain;
    }
    else if (weatherIconText == '010d')
    {
      weatherIconText = 'wi-day-rain';
    }
    else if (weatherIconText == '11d')
    {
      weatherIconText = commonThunderstorm;
    }
    else if (weatherIconText == '13d')
    {
      weatherIconText = commonSnow;
    }
    else if (weatherIconText == '50d')
    {
      weatherIconText = commonMist;
    }

    if (weatherIconText == '01n')
    {
      weatherIconText = 'wi-night-clear';
    }
    else if (weatherIconText == '02n')
    {
      weatherIconText = 'wi-night-cloudy';
    }
    else if (weatherIconText == '03n')
    {
      weatherIconText = commonScatteredClouds;
    }
    else if (weatherIconText == '04n')
    {
      weatherIconText = commonBrokenClouds;
    }
    else if (weatherIconText == '09n')
    {
      weatherIconText = commonShowerRain;
    }
    else if (weatherIconText == '010n')
    {
      weatherIconText = 'wi-night-rain';
    }
    else if (weatherIconText == '11n')
    {
      weatherIconText = commonThunderstorm;
    }
    else if (weatherIconText == '13n')
    {
      weatherIconText = commonSnow;
    }
    else if (weatherIconText == '50n')
    {
      weatherIconText = commonMist;
    }

    return weatherIconText;
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
                    getWeatherInfo();
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