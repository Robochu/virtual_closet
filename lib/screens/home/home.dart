import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/account/account.dart';
import 'package:virtual_closet/screens/camera_screen/image_gallery.dart';
import 'package:virtual_closet/screens/closet/closet.dart';
import 'package:virtual_closet/screens/home/calendar.dart';
import 'package:virtual_closet/screens/home/item_swipe.dart';
import 'package:virtual_closet/screens/home/notification_services.dart';
import 'package:virtual_closet/screens/home/recommendation.dart';
import 'package:virtual_closet/screens/home/weather.dart';
import 'package:virtual_closet/screens/home/globals.dart' as globals;
import 'package:virtual_closet/screens/laundry/laundry.dart';
import 'package:virtual_closet/screens/combinations/combo.dart';
import 'package:virtual_closet/service/database.dart';
import 'package:weather/weather.dart';
import 'package:collection/collection.dart';

/*
* Recommendation algorithm explanation:
* getRecommendation() : calls weather, temperature, calendar filters and populate attributes list
* with appropriate attributes (long, short, t-shirt, etc.)
* --- call getRecommendation() when you want to update attribute list because weather/temp/calendar has changed
*
* recommendation queue in buildRecommendation: call the RecommendationQueue class to compare the attribute list
* with all the items in the closet. +1 point if item has an attribute. If item is favorited, double the score
* so it will be on top. Items with 0 point (don't match) or are laundry will be removed.
* --- coupled with StreamBuilder to watch for changes in the database.
 */

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
    _selectedIndex = 1;
  }

  int _selectedIndex = 1;
  HomeView homepage = const HomeView();

  static const List<Widget> _widgetOptions = <Widget>[
    AccountPage(),
    HomeView(),
    Closet(),
    Laundry(),
    Combo(),
  ];

  //Method to track index of tabs for the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 0.0),
              child: IconButton(
                  tooltip: "Account",
                  icon: Icon(Icons.account_circle,
                      size: 35,
                      color: _selectedIndex == 0
                          ? Colors.lightBlueAccent
                          : Colors.black54),
                  onPressed: () {
                    _onItemTapped(0);
                  })),
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () => _onButtonPressed(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                IconButton(
                    tooltip: "Home",
                    icon: Icon(Icons.home,
                        size: 35,
                        color: _selectedIndex == 1
                            ? Colors.deepOrange
                            : Colors.black87),
                    onPressed: () {
                      _onItemTapped(1);
                    }),
                const Text("Home")
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                IconButton(
                    tooltip: "Closet",
                    icon: Icon(Icons.auto_awesome_mosaic,
                        size: 35,
                        color: _selectedIndex == 2
                            ? Colors.deepOrange
                            : Colors.black87),
                    onPressed: () {
                      _onItemTapped(2);
                    }),
                const Text("Closet")
              ]),

              const SizedBox(width: 40), //placeholder for
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                IconButton(
                    tooltip: "Laundry",
                    icon: Icon(Icons.auto_awesome,
                        size: 35,
                        color: _selectedIndex == 3
                            ? Colors.deepOrange
                            : Colors.black87),
                    onPressed: () {
                      _onItemTapped(3);
                    }),
                const Text("Laundry")
              ]), // FAB
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                IconButton(
                    tooltip: "Outfits",
                    icon: Icon(Icons.auto_fix_high,
                        size: 35,
                        color: _selectedIndex == 4
                            ? Colors.deepOrange
                            : Colors.black87),
                    onPressed: () {
                      _onItemTapped(4);
                    }),
                const Text("Outfits")
              ]), //
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
  const HomeView({
    Key? key,
  }) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    laundryFreq = 7;
    getWeatherInfo();
    getNotificationTime();
    getNotificationOnOff();
    _getLaundryFreq();
    _getLaundryNotification();
    getRecommendation();
  }

  String weatherText = '';
  double? currTemp = 0.0;
  double? feelLike = 0.0;
  String weatherIconText = '';
  double currentLongitude = 0.0;
  double currentLatitude = 0.0;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isNotificationOnOff = true;
  String actualIconCode = '';
  String top = '';
  String bottom = '';
  String shoes = '';
  late int laundryFreq;
  late bool laundryNotif;
  int prevCounter = 0;
  int counter = 0;
  List<String> attributes = <String>[];

  void _getLaundryFreq() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      laundryFreq = prefs.getInt('laundryFreq') ?? 7;
    });
  }

  void _getLaundryNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      laundryNotif = prefs.getBool('laundryNotif') ?? false;
    });
  }

  Future<void> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationHour = prefs.getInt('notificationHour') ?? 0;
    final notificationMinute = prefs.getInt('notificationMinute') ?? 0;

    if (notificationHour != 0 && notificationMinute != 0) {
      selectedTime =
          TimeOfDay(hour: notificationHour, minute: notificationMinute);
    }
  }

  Future<void> getNotificationOnOff() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationOnoFF = prefs.getBool('notificationOnOff') ?? 0;

    if (notificationOnoFF == 0) {
      isNotificationOnOff = false;
    } else {
      isNotificationOnOff = notificationOnoFF as bool;
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

    // If app can use current location get current latitude and longitude to get weather for current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    // Set latitude and longitude
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
    Weather wlatlong =
        await wf.currentWeatherByLocation(currentLatitude, currentLongitude);

    // Change weather text to text from api weather call
    if (mounted) {
      setState(() {
        print(wlatlong.toString());
        currTemp = wlatlong.temperature!.fahrenheit;
        Temperature? tempFeel = wlatlong.tempFeelsLike;
        feelLike = tempFeel!.fahrenheit;
        String weatherDescription = wlatlong.weatherDescription!;
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

  String addIfNotThere(String addThis, String toThat) {
    for (int i = 0; i < toThat.length; i++) {
      if (addThis.matchAsPrefix(toThat, i) != null) {
        return toThat;
      }
    }
    return toThat += addThis;
  }

  void addAttribute(List<String> atts) {
    for (var att in atts) {
      if (!attributes.contains(att)) {
        attributes.add(att);
      }
    }
  }

  // Helper function to translate weather icon code to weather code
  void weatherClothesFilter(String weatherIconText) {
    if (weatherIconText == '') {
      return;
    }

    if (weatherIconText == '01d') //sunny
    {
      addAttribute(["Short", "T-shirt", "Shorts", "Shoes", "Hat"]);
    } else if (weatherIconText == '02d') //cloudy
    {
      addAttribute(["T-shirt", "Pants", "Shoes"]);
    } else if (weatherIconText == '03d') //scattered cloud
    {
      addAttribute(["Shirt", "Pants", "Shoes"]);
    } else if (weatherIconText == '04d') //broken cloud
    {
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '09d') //shower rain
    {
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
    } else if (weatherIconText == '10d') //rain
    {
      addAttribute(["Long", "Shirt", "Pants", "Boots"]);
    } else if (weatherIconText == '11d') //thunderstorm
    {
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '13d') //snow
    {
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '50d') //mist
    {
      addAttribute(["T-shirt", "Pants", "Shoes"]);
    }

    if (weatherIconText == '01n') //night clear
    {
      addAttribute(["T-shirt", "Shorts", "Sandals"]);
    } else if (weatherIconText == '02n') {
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '03n') {
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '04n') {
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '09n') //shower rain
    {
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '10n') //thunderstorm
    {
      addAttribute(["Shirt", "Pants", "Boots"]);
    } else if (weatherIconText == '11n') //rain
    {
      addAttribute(["Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '13n') //snow
    {
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '50n') {
      //mist
      addAttribute(["T-shirt", "Pants", "Closed-toed-shoes"]);
    }
  }

  void calendarClothesFilter() {
    // If key words in calendar events like "interview" or "lunch" then replace categories
    String events = globals.EVENTSOFTODAY;
    for (int i = 0; i < events.length; i++) {
      if ('interview'.matchAsPrefix(events.toLowerCase(), i) != null) {
        addAttribute(["Suit", "Pants", "Shoes"]);
        top = 'Suit';
        bottom = 'Pants';
        shoes = 'Shoes';
      } else if ('lunch'.matchAsPrefix(events.toLowerCase(), i) != null) {
        addAttribute(["Shirt", "Pants", "Shoes"]);
        top = 'Shirts';
        bottom = 'Pants';
        shoes = 'shoes';
      } else if ('flight'.matchAsPrefix(events.toLowerCase(), i) != null) {
        addAttribute(["T-shirt", "Shorts", "Sneaker"]);
        top = 'T-shirt';
        bottom = 'Shorts';
        shoes = 'sneakers';
      }
    }
  }

  void timeClothesFilter(TimeOfDay currentTime, weatherIConCode) {
    if (weatherIConCode != '' || globals.EVENTSOFTODAY != '') {
      return;
    }
    // If user doesn't allow weather and has no google calendar hooked up then filter only using time
    if (currentTime.period.toString().substring(10, 12) == 'am') {
      addAttribute(["T-shirt", "Shorts", "Closed-toed-shoes"]);
      top = addIfNotThere("T-shirt", top);
      bottom = addIfNotThere("Shorts", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
      return;
    }
    if (currentTime.period.toString().substring(10, 12) == 'pm') {
      addAttribute(["Long", "Shirt", "Pants", "Closed-toed-shoes"]);
      top = addIfNotThere("Shirts", top);
      bottom = addIfNotThere("Pants", bottom);
      shoes = addIfNotThere("closed-toed-shoes", shoes);
      return;
    }
  }

  void temperatureClothesFilter(double? curr, double? feels) {
    if (curr! >= 70.0 && feels! >= 70) {
      addAttribute(["Short"]); //short sleeve if temp is > 70
    } else if (curr >= 70 && feels! < 70) {
      addAttribute(["Jacket"]); //bring a jacket
    } else if (curr < 70 && feels! < 70) {
      addAttribute(["Long"]);
    }
  }

  int getRandomInt() {
    var randomGenerator = Random();
    return randomGenerator.nextInt(50);
  }

  void getRecommendation() {
    // Get filters using helper functions
    weatherClothesFilter(actualIconCode);
    temperatureClothesFilter(currTemp, feelLike);
    calendarClothesFilter();
    timeClothesFilter(TimeOfDay.now(), actualIconCode);
  }

  // Time picker widget
  selectTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final TimeOfDay? timeChosen = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeChosen != null && timeChosen != selectedTime) {
      setState(() {
        selectedTime = timeChosen;
      });
    }
    prefs.setInt('notificationHour', selectedTime.hour);
    prefs.setInt('notificationMinute', selectedTime.minute);
  }

  Future<void> setNotification() async {
    final prefs = await SharedPreferences.getInstance();
    String currentDateTime = DateTime.now().toString();
    String userInputTime =
        (currentDateTime.substring(0, 11) + selectedTime.hour.toString()) +
            ":" +
            selectedTime.minute.toString() +
            ":" +
            "00.000000";

    //notifs.NotificationService().scheduleNotification(DateTime.parse(userInputTime), "message");
    print(DateTime.now().toString());
    print(userInputTime);
  }

  void addAlarm() {}

  Dialog getAlarmDialog() {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height - 350,
        width: MediaQuery.of(context).size.width + 50,
        color: Colors.white,
      ),
    );
  }

  int duration(String? str) {
    if (str == null) return 0;
    DateTime date = DateFormat.yMd().parse(str);
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return (difference.inDays + 1);
    } else if (difference.inDays == 1) {
      return (difference.inDays);
    }
    return difference.inDays;
  }

  countOverdue(List<Clothing>? closet) {
    if (closet == null || closet.isEmpty) return 0;
    prevCounter = counter;
    int temp = 0;

    for (var items in closet) {
      if (items.isLaundry && duration(items.inLaundryFor) >= laundryFreq) {
        temp++;
      }
    }
    counter = temp;
  }

  @override
  Widget build(BuildContext context) {
    if (globals.recommendationOnOff == 0) {
      //getRecommendation();
      globals.recommendationOnOff = 1;
    }

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
            Flexible(flex: 2, child: CalendarSummary())
          ],
        ),
        buildRecommendation(context),
        /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                              child: FloatingActionButton.extended(
                                heroTag: Text("Alarm"), //solve multiple heroes exception
                                label: const Text("View Alarms"),
                                onPressed: () {
                                  showDialog(builder: (BuildContext context) {return getAlarmDialog();}, context: context);
                                },
                                tooltip: 'New alarm',
                                icon: new Icon(Icons.alarm),
                            ),
                        ),
                      ),
                    ),
                     ElevatedButton(
                      onPressed: () {
                        selectTime(context);
                      },
                      child: Text("Notification Time: " + selectedTime.hourOfPeriod.toString() + selectedTime.toString().substring(12, 15) + " " + selectedTime.period.toString().substring(10,12)),
                    ),
                    Switch(
                        value: isNotificationOnOff,
                        onChanged: (value) {
                          setState(() {
                            //setNotificationOnoFF(value);
                            isNotificationOnOff = value;
                            getRecommendation();
                          });
                        }
                    ),
                  ],
                ),*/
        const ListTile(
            dense: true,
            visualDensity: VisualDensity(horizontal: 0.0, vertical: -4.0),
            tileColor: Colors.transparent,
            leading: Text("Reminders",
                style: TextStyle(fontWeight: FontWeight.bold))),
        TimerBuilder.periodic(const Duration(seconds: 20), builder: (context) {
          _getLaundryFreq();
          return buildReminders(context);
        })
      ],
    )));
  }

  Widget buildRecommendation(BuildContext context) {
    return StreamBuilder<List<Clothing>>(
        stream:
            DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).closet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Clothing> closet = snapshot.data ?? <Clothing>[];
            PriorityQueue<Recommendation> recommendations =
                RecommendationQueue(closet: closet, attributes: attributes)
                    .queue;
            if (closet.isEmpty || recommendations.isEmpty) {
              return Container(
                  alignment: Alignment.center,
                  height: 400.0,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text("There is no recommendation right now :("));
            }
            List<ItemSwipe> items = <ItemSwipe>[];
            while (recommendations.isNotEmpty) {
              items
                  .add(ItemSwipe(item: recommendations.removeFirst().clothing));
            }
            return Container(
                alignment: Alignment.center,
                height: 400.0,
                padding: const EdgeInsets.only(left: 60.0),
                child: Stack(
                  children: items,
                ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget buildReminders(BuildContext context) {
    return StreamBuilder<List<Clothing>>(
        stream:
            DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).closet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Clothing>? clothes = snapshot.data;
            countOverdue(clothes);
            _getLaundryNotification();
            if (counter != prevCounter && counter > 0 && laundryNotif) {
              NotificationService().showNotification((counter == 1)
                  ? "You have 1 overdue item. Wash it now!"
                  : "You have $counter overdue items. Let's do some laundry!");
            }
            //print(counter);
            if (counter == 0) {
              return const Padding(
                  padding: EdgeInsets.only(top: 0.0, bottom: 50.0),
                  child: Center(
                      child: Text(
                          "Good job! You don't have any reminders right now",
                          style: TextStyle(color: Colors.black45))));
            }
            return Padding(
                padding: const EdgeInsets.only(
                    bottom: 50.0, right: 16.0, left: 16.0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.black,
                    )),
                    child: ListTile(
                      dense: true,
                      visualDensity:
                          const VisualDensity(horizontal: 0.0, vertical: -4.0),
                      title: ((counter == 1)
                          ? const Text("You have 1 overdue item. Wash it now!")
                          : Text(
                              "You have $counter overdue items. Let's do some laundry!")),
                      onTap: () {},
                    )));
          } else {
            return const Center(
                child: Text("Good job! You don't have any reminders right now",
                    style: TextStyle(color: Colors.black45)));
          }
        });
  }
}
