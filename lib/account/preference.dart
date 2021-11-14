import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreferencePage extends StatefulWidget {
  @override
  _PreferencePageState createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  bool laundrySwitch = false;
  double laundryFreq = 7;
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
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
            child: SingleChildScrollView(
                child: ListView(shrinkWrap: true,
                    children: <Widget>[
                      const ListTile(
                        dense: true,
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: EdgeInsets.only(left: 1.0),
                        tileColor: Colors.transparent,
                          leading: Text("Laundry preferences",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,

                          )
                        ),
                          child:ListTile(
                          dense: true,
                          visualDensity: VisualDensity(horizontal: 0, vertical: 0),
                         title: const Text(
                                "Enable laundry notifications from the app",
                                style: const TextStyle(fontSize: 13)),
                            trailing: Transform.scale(
                                scale: 0.6,
                                child: CupertinoSwitch(
                                    value: laundrySwitch,
                                    onChanged: (bool value) {
                                      setState(() {
                                        laundrySwitch = value;
                                      });
                                    },
                                    activeColor: Colors.lightGreen)
                            ))),
                      Container(
                          decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(),
                            left: BorderSide(),
                            right: BorderSide()
                          )
                      ),
                          child: ListTileTheme(
                        dense: true,
                        child: ExpansionTile(
                          title: Text("I want to do laundry every ${laundryFreq.toStringAsFixed(0)} days",
                              style: const TextStyle(fontSize: 13)),
                          children: [
                            Slider(
                                value: laundryFreq,
                                min: 1,
                                max: 100,
                                onChanged: (value) {
                                  setState(() {
                                    laundryFreq = value;
                                  });
                                }
                            )]))),
                    ],
                ),

            )
        ));
  }


}
