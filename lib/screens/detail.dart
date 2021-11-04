import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../clothes.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key,  required this.clothing})
      : super(key: key);

  final Clothing clothing;

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
  late final colorController;
  late final sleeveController;
  late final materialController;

  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    unedited = Clothing.clone(widget.clothing);
    clothing = Clothing.clone(widget.clothing);
    initSleeves = clothing!.sleeves;
    initColor = clothing!.color;
    initMaterials = clothing!.materials;
    colorController = TextEditingController(text: initColor);
    sleeveController = TextEditingController(text: initSleeves);
    materialController = TextEditingController(text: initMaterials);
  }

  @override
  void dispose() {
    super.dispose();
    colorController.dispose();
    sleeveController.dispose();
    materialController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  ),
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
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          filled: true,
                          labelText: 'Add to laundry basket?',
                        ),
                        isExpanded: false,
                        hint: const Text('Choose an option'),
                        value: (clothing!.isLaundry != false)
                            ? "Yes"
                            : "No",
                        onChanged: _isEditable ?  (String? status) {
                          setState(() {
                            (status == "Yes") ? clothing!.isLaundry = true : clothing!.isLaundry = false;
                          });
                        } : null,
                        items: <String>[
                          'Yes',
                          'No'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  ) : Container(
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
                  ),
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
                              print("Taking input from user");
                              clothing!.color = colorController.text;
                              clothing!.sleeves = sleeveController.text;
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
