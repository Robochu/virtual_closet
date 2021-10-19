import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../clothes.dart';

class LaundryDetailPage extends StatefulWidget {
  const LaundryDetailPage({Key? key,  required this.clothing})
      : super(key: key);

  final Clothing clothing;

  @override
  State<LaundryDetailPage> createState() => _LaundryDetailPageState();
}

class _LaundryDetailPageState extends State<LaundryDetailPage> {
  Clothing? unedited;
  Clothing? clothing;
  late String initSleeves;
  late String initMaterials;
  late String initColor;
  final _formKey = GlobalKey<FormState>();
  late final colorController;
  late final sleeveController;
  late final materialController;

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
    return Scaffold();
  }
}
