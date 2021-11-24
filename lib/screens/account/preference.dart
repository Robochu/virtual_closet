import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencePage extends StatefulWidget {
  @override
  _PreferencePageState createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  late bool laundrySwitch;
  late int laundryFreq;

  @override
  void initState() {
    super.initState();
    laundrySwitch = false;
    laundryFreq = 7;
    getInitialValues();
  }

  void getInitialValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      laundrySwitch = (prefs.getBool('laundryNotif') ?? false);
      laundryFreq = (prefs.getInt('laundryFreq') ?? 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text("Preferences"),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
            child: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  const ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      contentPadding: EdgeInsets.only(left: 1.0),
                      tileColor: Colors.transparent,
                      leading: Text(
                        "Laundry preferences",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      )),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.black,
                      )),
                      child: ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          title: const Text(
                              "Enable laundry notifications from the app",
                              style: TextStyle(fontSize: 13)),
                          trailing: Transform.scale(
                              scale: 0.6,
                              child: CupertinoSwitch(
                                  value: laundrySwitch,
                                  onChanged: (bool value) {
                                    setState(() async {
                                      laundrySwitch = value;
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool(
                                          'laundryNotif', laundrySwitch);
                                    });
                                  },
                                  activeColor: Colors.lightGreen)))),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(),
                              left: BorderSide(),
                              right: BorderSide())),
                      child: ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        title: (laundryFreq == 1)
                            ? const Text(
                            "I want to do laundry every 1 day",
                            style: TextStyle(fontSize: 13))
                            : Text(
                            "I want to do laundry every ${laundryFreq.toStringAsFixed(0)} days",
                            style: const TextStyle(fontSize: 13)),
                        trailing: TextButton(
                          child: const Text("Edit", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) => StatefulBuilder(builder:
                                        (BuildContext context,
                                            void Function(void Function())
                                                setStateIn) {
                                      return SizedBox(
                                          height: 150,
                                          child: Column(children: [
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                    minimumSize: Size.zero,
                                                    padding: EdgeInsets.zero,
                                                    alignment:
                                                        Alignment.topRight),
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.setInt('laundryFreq',
                                                      laundryFreq);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Save")),
                                            SizedBox(
                                                height: 100,
                                                child: Slider(
                                                    value: laundryFreq.toDouble(),
                                                    min: 1,
                                                    max: 30,
                                                    divisions: 30,
                                                    label: "$laundryFreq",
                                                    onChanged: (value) {
                                                      setStateIn(() { //update slider
                                                        laundryFreq = value.toInt();
                                                      });
                                                      setState(() { //update outside
                                                        laundryFreq = value.toInt();
                                                      });
                                                    }))
                                          ]));
                                    }));
                          },
                        ),
                      )),
                ],
              ),
            )));
  }
}
