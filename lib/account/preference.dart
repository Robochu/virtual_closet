import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

class PreferencePage extends StatefulWidget {
  @override
  _PreferencePageState createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  bool laundrySwitch = false;
  var laundryFreq = 7;
  TextEditingController laundryFreq_controller = TextEditingController(text: "7");

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
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildLaundryPreferences(context),
                      const SizedBox(height: 20),
                    ]))));
  }

  Widget buildLaundryPreferences(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            )),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("Laundry preferences",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Enable laundry notifications from the app",
                      style: TextStyle(fontSize: 12)),
                  Transform.scale(
                    scale: 0.6,
                      child: CupertinoSwitch(
                      value: laundrySwitch,
                      onChanged: (bool value) {
                        setState(() {
                          laundrySwitch = value;
                        });
                      },
                      activeColor: Colors.lightGreen)
              )]),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text("I want to wash my clothes every  ",
                      style: TextStyle(fontSize: 12)),
                 Container(
                    width: 35,
                      height: 15,
                      child: TextFormField(
                          style: const TextStyle(fontSize: 15),
                    controller: laundryFreq_controller,
                    keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly]
                  )),

                  const Text(" days", style: TextStyle(fontSize: 12))
                ],
              )
            ],
          ),

        )
    );
  }
}
