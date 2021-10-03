import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen/take_picture_screen.dart';
import 'camera_screen/all_camera.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Ensure plugin services are initialized
  final cameras = await availableCameras(); //Get list of available cameras
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera: firstCamera));
}

class MyApp extends StatelessWidget {
  final firstCamera;
  const MyApp({Key? key, this.firstCamera}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title: 'Flutter Demo Home Page',
          camera: firstCamera,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final camera;
  const MyHomePage({Key? key, required this.title, this.camera}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;

  
  //list of widgets - TEMPORARY for initial display only
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Closet',
      style: optionStyle,
    ),
    Text(
      'Camera',
      style: optionStyle,
    ),
    Text(
      'Laundry',
      style: optionStyle,
    ),
    Text(
      'Account',
      style: optionStyle,
    ),
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic), //TODO: change icon
            label: 'Closet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add an item',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Laundry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          )
        ],
        currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}



