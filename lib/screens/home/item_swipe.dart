import 'package:flutter/material.dart';
import 'package:flutter_swipable/flutter_swipable.dart';

/*
* Class to for each swipable card on the recommendation section
 */

class ItemSwipe extends StatelessWidget {
  const ItemSwipe({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Swipable(
      child: Container(
        height: 350,
        width: 300,
        padding: EdgeInsets.only(top: 50.0),
        decoration: BoxDecoration(
          color: Colors.grey,),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}