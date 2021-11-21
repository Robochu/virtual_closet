import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/service/database.dart';
import 'laundry/toggle.dart';
import '../clothes.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.clothing, this.editable = false})
      : super(key: key);

  final Clothing clothing;
  final bool editable;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Clothing? unedited;
  Clothing? clothing;
  late String initSleeves;
  late String initMaterials;
  late String initColor;
  final _formKey = GlobalKey<FormState>();
  /*
  late final colorController;
  late final sleeveController;*/
  late final materialController;
  late int laundryFreq;

  late bool _isEditable;

  @override
  void initState() {
    super.initState();
    unedited = Clothing.clone(widget.clothing);
    clothing = Clothing.clone(widget.clothing);
    initSleeves = clothing!.sleeves;
    initColor = clothing!.color;
    initMaterials = clothing!.materials;
    laundryFreq = 7;
    /*
    colorController = TextEditingController(text: initColor);
    sleeveController = TextEditingController(text: initSleeves);*/
    materialController = TextEditingController(text: initMaterials);
    _isEditable = widget.editable;
    _getLaundryFreq();
  }

  @override
  void dispose() {
    super.dispose();
    /*
    colorController.dispose();
    sleeveController.dispose();*/
    materialController.dispose();
  }
  void _getLaundryFreq() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      laundryFreq = prefs.getInt('laundryFreq') ?? 7;
    });
  }

  String duration(String? str) {
    if(str == null) return "";
    DateTime date = DateFormat.yMd().parse(str);
    Duration difference = DateTime.now().difference(date);
    if(difference.inDays == 0) {
      return (difference.inDays + 1).toString() + " day";
    } else if(difference.inDays == 1) {
        return (difference.inDays).toString() + " day";
    }
      return difference.inDays.toString() + " days";

  }

  bool isOverdue(String? str)  {
    if(str == null) return false;
    DateTime date = DateFormat.yMd().parse(str);
    Duration difference = DateTime.now().difference(date);
    if(difference.inDays >= laundryFreq) {
      return true;
    }
    return false;

  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    return Scaffold(
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (widget.clothing.link! != '')
                      ? Image(
                    image: NetworkImage(widget.clothing.link!),

                  )
                      : Image.file(File(widget.clothing.path!)),

                  Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          filled: true,
                          labelText: 'Category',
                        ),
                        isExpanded: true,
                        hint: const Text('Choose a category'),
                        value: (clothing!.category != '')
                            ? clothing!.category
                            : 'Tops',
                        onChanged: _isEditable ? (String? value) {
                          setState(() {
                            clothing!.category = value!;
                          });
                        } : null,
                        items: <String>[
                          'Tops',
                          'Bottoms',
                          'Outerwear',
                          'Shoes',
                          'Accessories'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          filled: true,
                          labelText: 'Clothing item',
                        ),
                        isExpanded: true,
                        hint: const Text('What exactly is it?'),
                        value: (clothing!.item != '')
                            ? clothing!.item
                            : 'T-shirt',
                        onChanged: _isEditable ? (String? value) {
                          setState(() {
                            clothing!.item = value!;
                          });
                        } : null,
                        items: <String>[
                          'Hat', 'Jacket', 'Pants', 'Shoes', 'Shorts', 'Suit', 'T-shirt', 'Other'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  ),
                  //DropDown for colors, length
                  Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          filled: true,
                          labelText: 'Color',
                        ),
                        isExpanded: true,
                        hint: const Text('Choose a color'),
                        value: (clothing!.color != '')
                            ? clothing!.color
                            : 'Black',
                        onChanged: _isEditable ? (String? value) {
                          setState(() {
                            clothing!.color = value!;
                          });
                        } : null,
                        items: <String>[
                          'Black', 'Blue', 'Brown', 'Grey', 'Green', 'Orange', 'Pink', 'Purple', 'Red', 'White', 'Yellow', 'Multicolor'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          filled: true,
                          labelText: 'Length',
                        ),
                        isExpanded: true,
                        hint: const Text('How long is it?'),
                        value: (clothing!.sleeves != '')
                            ? clothing!.sleeves
                            : 'Short',
                        onChanged: _isEditable ? (String? value) {
                          setState(() {
                            clothing!.sleeves = value!;
                          });
                        } : null,
                        items: <String>[
                          'Short',
                          'Long',
                          'N/A'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  ),

                  //comment out TextFormField below, don't delete until we're set with everything
                  /*
                  TextFormField(
                    enabled: _isEditable,
                    decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Sleeve type',
                        hintText: 'Short-sleeve, long-sleeve, tank tops, etc.'),
                    controller: sleeveController,
                  ),
                  TextFormField(
                    enabled: _isEditable,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Color',
                    ),
                    controller: colorController,
                  ),*/

                  //keep Materials as text field
                  TextFormField(
                    enabled: _isEditable,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Materials',
                    ),
                    controller: materialController,
                  ),
                  (_isEditable) ?
                  Align(
                      alignment: Alignment.center,
                      child: AnimatedToggle(
                          values: const ['Closet', 'Laundry'],
                          preSet: clothing!.isLaundry,
                          onToggleCallback: (value) {
                            setState(() {
                              (value == 1) ? clothing!.isLaundry = true : clothing!.isLaundry = false;
                              if(value == 1) {
                                clothing!.inLaundryFor = DateFormat.yMd().format(DateTime.now());
                                DatabaseService(uid: user!.uid).updateLaundryDetail(clothing!, DateTime.now());
                              }
                            });
                          }
                      )
                  ) : Column (
                      children: <Widget> [
                        Container(
                          height: 10,
                        ), Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: null,
                              child: (clothing!.isLaundry) ? const Text(
                                  'In Laundry') : const Text('In Closet'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)
                                  )
                              ),
                            )
                        )
                      ]
                  ),
                  (clothing!.isLaundry)
                  ? Padding(padding: EdgeInsets.only(left: 20.0),
                      child: Text("This item has been in laundry for ${duration(clothing!.inLaundryFor)}",
                  style: TextStyle(color: (isOverdue(clothing!.inLaundryFor)) ? Colors.red: Colors.black45, fontStyle: FontStyle.italic)))
                      : const Text(""),
                  if (_isEditable) Row(
                    children: <Widget>[
                      Container(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                          ),
                          child: const Text('Cancel'),
                          onPressed: () => {
                            _isEditable = false,
                            setState(() {})
                          },
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          child: const Text('Save'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              /*
                              clothing!.color = colorController.text;
                              clothing!.sleeves = sleeveController.text;*/
                              clothing!.materials = materialController.text;
                              clothing!.upload();
                            }
                            clothing == unedited
                                ? null
                                : () {
                              clothing!.upload();
                              setState(() {
                                unedited = Clothing.clone(clothing!);
                              });
                            };
                            //exit out of detail page
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            child: const Text('Delete'),
                            onPressed: () => {clothing!.delete(),
                              Navigator.of(context).popUntil((route) => route.isFirst)}),
                      ),
                      Container(
                        width: 20,
                      ),
                    ],
                  ) else Row(
                      children: <Widget>[
                        Container(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.redAccent,
                            ),
                            child: const Text('Edit'),
                            onPressed: () => {
                              _isEditable = true,
                              setState(() {})
                            },
                          ),
                        ),
                        Container(
                          width: 20,
                        ),
                      ]
                  ),
                  Container(
                    height: 10,
                  ),
                ],
              ),
            )));
  }
}
