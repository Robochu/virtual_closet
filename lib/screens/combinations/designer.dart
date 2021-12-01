import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/closet/closet.dart';
import 'package:virtual_closet/screens/detail.dart';
import 'package:virtual_closet/service/database.dart';

import 'outfit.dart';

class Designer extends StatefulWidget {
  const Designer({Key? key, required this.outfit}) : super(key: key);

  final Outfit outfit;

  @override
  State<Designer> createState() => _DesignerState();
}

class _DesignerState extends State<Designer> {
  late Outfit outfit;
  bool _isEdit = false;
  bool _nameEdit = false;
  TextEditingController name_controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    outfit = widget.outfit;
    name_controller.text = outfit.name;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:TextField(
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          controller: name_controller,
          enabled: _nameEdit,
        ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _nameEdit = !_nameEdit;
                  });
                  if(name_controller.text != outfit.name) {
                    DatabaseService(uid: user!.uid).updateOutfit(name_controller.text, outfit.clothes, outfit.id);
                  }
                },
                icon: _nameEdit ? const Icon(Icons.check) : const Icon(Icons.edit))
            ]
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate( //add an extra box if in edit mode
                  _isEdit ? outfit.clothes.length+1 : outfit.clothes.length, (index) {
                    if(index == outfit.clothes.length) {
                      return InkWell(
                        onTap: () async {
                          final result = await Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  Closet(isSelectable: true))
                          );
                          setState(() {
                            outfit.clothes.add(result);
                          });
                        },
                        child: Padding (
                            padding: const EdgeInsets.all(15),
                                child: Container(

                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(20),
                                    color: Colors.black45,
                                      strokeWidth: 1,
                                      child: const Center(
                                          child: Icon(Icons.add, color: Colors.black45)
                                      )
                                  )
                                  ),
                            )
                      );
                    }
                return InkWell(
                  child: Padding (
                      padding: const EdgeInsets.all(15),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            constraints: const BoxConstraints.expand(
                              height: 200.0,
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(outfit.clothes[index].link!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: (outfit.clothes[index].isLaundry) ? const Text('In Laundry',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow (
                                          blurRadius: 10.0,
                                          color: Colors.black
                                      )
                                    ]
                                )
                            ) : null,
                          )
                      )
                  ),
                  onTap: () => openClothing(context, outfit.clothes[index]),
                );
              }),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 20,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text(_isEdit ? 'Cancel' : 'Edit Outfit'),
                  onPressed: () {
                    setState(() {
                      _isEdit = !_isEdit;
                    });

                  }),
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
                      setState(() {
                        _isEdit = false;
                      });
                      outfit.name = name_controller.text;
                      DatabaseService(uid: user!.uid).updateOutfit(name_controller.text, outfit.clothes, outfit.id);
                      Navigator.pop(context);
                    }),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void openClothing(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(clothing: clothing),
      ),
    );
  }
}