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
import 'package:virtual_closet/screens/combinations/outfit.dart';
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
    _getLaundryFreq();
    _getLaundryNotification();
    getRecommendation();
    getOutfit();
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
  List<Outfit> outfits = <Outfit>[];
  String weather = '';
  int numberOfAlarms = 0;
  String alarm1 = '';
  String alarm2 = '';
  String alarm3 = '';

  void _getLaundryFreq() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      laundryFreq = prefs.getInt('laundryFreq') ?? 7;
    });
  }

  void getOutfit() async {
    List<Outfit> outfit =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .outfits
            .first;
    setState(() {
      outfits = [...outfit];
    });
  }

  void _getLaundryNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      laundryNotif = prefs.getBool('laundryNotif') ?? false;
    });
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
    String temp = '';
    if (weatherIconText == '01d') {
      temp = "Sunny/Clear";
      addAttribute(["Short", "T-shirt", "Shorts", "Shoes", "Hat"]);
      weatherIconText = 'wi-day-sunny';
    } else if (weatherIconText == '02d') {
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Shoes"]);
      weatherIconText = 'wi-day-cloudy-high';
    } else if (weatherIconText == '03d') {
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Shoes"]);
      weatherIconText = commonScatteredClouds;
    } else if (weatherIconText == '04d') {
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Shoes"]);
      weatherIconText = commonBrokenClouds;
    } else if (weatherIconText == '09d') {
      temp = "Rainy";
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
      weatherIconText = commonShowerRain;
    } else if (weatherIconText == '10d') {
      temp = "Rainy";
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
      weatherIconText = 'wi-day-rain';
    } else if (weatherIconText == '11d') {
      temp = "Rainy";
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
      weatherIconText = commonThunderstorm;
    } else if (weatherIconText == '13d') {
      temp = "Snowy";
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
      weatherIconText = commonSnow;
    } else if (weatherIconText == '50d') {
      temp = "Cloudy";
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
      weatherIconText = commonMist;
    }

    if (weatherIconText == '01n') {
      temp = "Sunny/Clear";
      weatherIconText = 'wi-night-clear';
    } else if (weatherIconText == '02n') {
      temp = "Cloudy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = 'wi-night-cloudy';
    } else if (weatherIconText == '03n') {
      temp = "Cloudy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = commonScatteredClouds;
    } else if (weatherIconText == '04n') {
      temp = "Cloudy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = commonBrokenClouds;
    } else if (weatherIconText == '09n') {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = commonShowerRain;
    } else if (weatherIconText == '10n') {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = 'wi-night-rain';
    } else if (weatherIconText == '11n') {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = commonThunderstorm;
    } else if (weatherIconText == '13n') {
      temp = "Snowy";
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
      weatherIconText = commonSnow;
    } else if (weatherIconText == '50n') {
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Closed-toed-shoes"]);
      weatherIconText = commonMist;
    }
    setState(() {
      weather = temp;
    });
    return weatherIconText;
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
    print("In weather");
    String temp = '';
    if (weatherIconText == '01d') //sunny
    {
      temp = "Sunny";
      addAttribute(["Short", "T-shirt", "Shorts", "Shoes", "Hat"]);
    } else if (weatherIconText == '02d') //cloudy
    {
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Shoes"]);
    } else if (weatherIconText == '03d') //scattered cloud
    {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Shoes"]);
    } else if (weatherIconText == '04d') //broken cloud
    {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '09d') //shower rain
    {
      temp = "Rainy";
      addAttribute(["Long", "Shirt", "Pants", "Shoes"]);
    } else if (weatherIconText == '10d') //rain
    {
      temp = "Rainy";
      addAttribute(["Long", "Shirt", "Pants", "Boots"]);
    } else if (weatherIconText == '11d') //thunderstorm
    {
      temp = "Rainy";
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '13d') //snow
    {
      temp = "Snowy";
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '50d') //mist
    {
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Shoes"]);
    }

    if (weatherIconText == '01n') //night clear
    {
      addAttribute(["T-shirt", "Shorts", "Sandals"]);
    } else if (weatherIconText == '02n') {
      temp = "Cloudy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '03n') {
      temp = "Cloudy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '04n') {
      temp = "Cloudy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '09n') //shower rain
    {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Closed-toed-shoes"]);
    } else if (weatherIconText == '10n') //thunderstorm
    {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Boots"]);
    } else if (weatherIconText == '11n') //rain
    {
      temp = "Rainy";
      addAttribute(["Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '13n') //snow
    {
      temp = "Snowy";
      addAttribute(["Long", "Shirt", "Pants", "Boots", "Jacket"]);
    } else if (weatherIconText == '50n') {
      //mist
      temp = "Cloudy";
      addAttribute(["T-shirt", "Pants", "Closed-toed-shoes"]);
    }
    setState(() {
      weather = temp;
    });
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

  void temperatureClothesFilter(double? curr, double? feels) {
    if (curr! >= 70.0 && feels! >= 70) {
      addAttribute(["Short"]); //short sleeve if temp is > 70
    } else if (curr >= 70 && feels! < 70) {
      addAttribute(["Jacket"]); //bring a jacket
    } else if (curr < 70 && feels! < 70) {
      addAttribute(["Long"]);
    }
  }

  // Time picker widget
  selectTime(BuildContext context) async {        
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null && timeOfDay != selectedTime)
    {
      String alarmToEdit = "alarm" + (numberOfAlarms + 1).toString();
      setState(() {
        selectedTime = timeOfDay;
      });
      print(alarmToEdit + 'changed' + selectedTime.format(context));
      prefs.setString(alarmToEdit, selectedTime.toString());
    }
    getAllAlarms();
    Navigator.of(context, rootNavigator: true).pop(true);
    showDialog(builder: (BuildContext context) {return getAlarmDialog();}, context: context);
  }

  editTime(BuildContext context, alarmId) async {        
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      prefs.setString("alarm" + alarmId.toString(), selectedTime.toString());
      getAllAlarms();
    }
    Navigator.of(context, rootNavigator: true).pop(true);
    showDialog(builder: (BuildContext context) {return getAlarmDialog();}, context: context);    
  }

  deleteAlarm(alarmId) async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (alarmId == 1 && numberOfAlarms == 3)
    {
      TimeOfDay alarm2TOD = TimeOfDay(
        hour: int.parse(alarm2.substring(10, 12)),
        minute: int.parse(alarm2.substring(13, 15)),
      );
      TimeOfDay alarm3TOD = TimeOfDay(
        hour: int.parse(alarm3.substring(10, 12)),
        minute: int.parse(alarm3.substring(13, 15)),
      );
      alarm1 = alarm2TOD.toString();
      alarm2 = alarm3TOD.toString();
      prefs.setString('alarm1', alarm1);
      prefs.setString('alarm2', alarm2);
      prefs.setString('alarm3', "");
      getAllAlarms();
    }
    else if (alarmId == 1 && numberOfAlarms == 2)
    {
      TimeOfDay alarm2TOD = TimeOfDay(
        hour: int.parse(alarm2.substring(10, 12)),
        minute: int.parse(alarm2.substring(13, 15)),
      );
      alarm1 = alarm2TOD.toString();
      prefs.setString('alarm1', alarm1);
      prefs.setString('alarm2', "");
      getAllAlarms();
    }
    else if (alarmId == 1 && numberOfAlarms == 1)
    {
      prefs.setString('alarm1', "");
      getAllAlarms();
    }
    else if (alarmId == 2 && numberOfAlarms == 3)
    {
      TimeOfDay alarm3TOD = TimeOfDay(
        hour: int.parse(alarm3.substring(10, 12)),
        minute: int.parse(alarm3.substring(13, 15)),
      );
      alarm2 = alarm3TOD.toString();
      prefs.setString('alarm2', alarm2);
      prefs.setString('alarm3', "");
      getAllAlarms();
    }
    else if (alarmId == 2 && numberOfAlarms == 2)
    {
      prefs.setString('alarm2', "");
      getAllAlarms();
    }
    else
    {
      prefs.setString('alarm3', "");
      getAllAlarms();
    }

    Navigator.of(context, rootNavigator: true).pop(true);
    showDialog(builder: (BuildContext context) {return getAlarmDialog();}, context: context); 
  }

  Future<void> getAllAlarms()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    alarm1 = prefs.getString('alarm1') ?? "";
    alarm2 = prefs.getString('alarm2') ?? "";
    alarm3 = prefs.getString('alarm3') ?? "";
    numberOfAlarms = 0;

    if (alarm1 != "")
    {
      numberOfAlarms++;
    }
    if (alarm2 != "")
    {
      numberOfAlarms++;
    }
    if (alarm3 != "")
    {
      numberOfAlarms++;
    }
  }

  bool checkNumberOfAlarms() 
  {
    if (numberOfAlarms == 3)
    {
      return true;
    }
    return false;
  }

  Widget makeAlarmWidget(alarmId)
  {
    String inputTime = "";
    TimeOfDay inputTimeTOD = TimeOfDay.now();

    if (alarmId == 1)
    {
      inputTime = alarm1;
    }
    else if (alarmId == 2)
    {
      inputTime = alarm2;
    }
    else
    {
      inputTime = alarm3;
    }

    if (inputTime == "")
    {
      return const Spacer();
    }
    else
    {
      inputTimeTOD = TimeOfDay(
        hour: int.parse(inputTime.substring(10, 12)),
        minute: int.parse(inputTime.substring(13, 15)),
      );
    }

    return Column(children: [
      Row(children: [
      Text(
        inputTimeTOD.format(context).substring(0, inputTimeTOD.format(context).length - 2) + 
        inputTimeTOD.format(context).substring(inputTimeTOD.format(context).length - 2, inputTimeTOD.format(context).length).toLowerCase(),
        textAlign: TextAlign.left, 
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
      ),
      const Spacer(),
      FloatingActionButton(
        onPressed: () => editTime(context, alarmId), 
        child: const Icon(Icons.settings),
        mini: true,
      ),
      FloatingActionButton(
        onPressed: () => deleteAlarm(alarmId),
        child: const Icon(Icons.delete),
        mini: true,
      )
    ],)
    ],
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }

  Widget getAlarmsText()
  {    
    if (alarm1 == "" && alarm2 == "" && alarm3 == "")
    {
      return const Text("you have none");
    }

    return Column(children: [
      Expanded(child: Column(
            children: <Widget>[
                   for (int i = 1; i <= 3; i++)
                      makeAlarmWidget(i),
                      const SizedBox(height: 10,),
                     ],
            ),)
    ],);
  }

  Dialog getAlarmDialog()
  {
    return Dialog(
      child: Container(
                height: 320,
                width: 400,
                color: Colors.white,
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                    const Text("Your Alarms", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 5.5,
                      indent: 5.5,
                      endIndent: 5.5,
                    ),
                    Expanded(
                      child: getAlarmsText()
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                        const Divider(
                          color: Colors.black,
                          thickness: 5.5,
                          indent: 5.5,
                          endIndent: 5.5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                        FloatingActionButton(
                          onPressed: checkNumberOfAlarms() ? null : () => selectTime(context),
                          child: const Icon(Icons.alarm_add),
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0),)
                      ],),
                      const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10),)],
                      )
                    )
                  ],
                )
              ),
    );
  }

  void getRecommendation() {
    // Get filters using helper functions
    weatherClothesFilter(actualIconCode);
    temperatureClothesFilter(currTemp, feelLike);
    calendarClothesFilter();
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

  Future<void> onRefresh() async {
    getWeatherInfo();
    _getLaundryFreq();
    _getLaundryNotification();
    getOutfit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: Scaffold(
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
            const ListTile(
                dense: true,
                visualDensity: VisualDensity(horizontal: 0.0, vertical: -4.0),
                tileColor: Colors.transparent,
                leading: Text("Reminders",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            buildReminders(context)
          ],
        ))));
  }

  Widget buildRecommendation(BuildContext context) {
    return StreamBuilder<List<Clothing>>(
        stream:
            DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).closet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Clothing> closet = snapshot.data ?? <Clothing>[];
            PriorityQueue<Recommendation> recommendations = RecommendationQueue(
                    closet: closet,
                    attributes: attributes,
                    outfits: outfits,
                    weather: weather)
                .queue;
            if (closet.isEmpty || recommendations.isEmpty) {
              return Container(
                  alignment: Alignment.center,
                  height: 400.0,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text("There is no recommendation right now :("));
            }
            List<ItemSwipe> items = <ItemSwipe>[];
            items.clear();
            while (recommendations.isNotEmpty) {
              items
                  .add(ItemSwipe(item: recommendations.removeFirst().clothing));
            }
            //for display message when runs out of card
            items.add(ItemSwipe(
                item: Clothing.usingLink(
                    "", "not", "", "", "", "", "", "", false, "", false)));

            List<ItemSwipe> reversed = items.reversed.toList();

            return Container(
                alignment: Alignment.center,
                height: 400.0,
                padding: const EdgeInsets.only(left: 60.0),
                child: Stack(
                  children: reversed,
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
