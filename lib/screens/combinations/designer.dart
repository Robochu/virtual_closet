import 'package:flutter/material.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/screens/detail.dart';

import 'outfit.dart';

class Designer extends StatefulWidget {
  const Designer({Key? key, required this.outfit}) : super(key: key);

  final Outfit outfit;

  @override
  State<Designer> createState() => _DesignerState();
}

class _DesignerState extends State<Designer> {
  late Outfit outfit;

  @override
  void initState() {
    super.initState();
    outfit = widget.outfit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(outfit.clothes.length, (index) {
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
                    primary: Colors.red,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Container(
                width: 20,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: const Text('Edit'),
                  onPressed: () {
                    // TODO Divay, edit the closet class to allow selecting clothes and open it here.
                    // TODO this page is for viewing which clothes are in the outfit, not selecting them.
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
                      // TODO Maeve
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