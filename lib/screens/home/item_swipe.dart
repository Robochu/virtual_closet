import 'package:flutter/material.dart';
import 'package:flutter_swipable/flutter_swipable.dart';
import 'package:intl/intl.dart';

import '../../clothes.dart';

/*
* Class to for each swipable card on the recommendation section
 */

class ItemSwipe extends StatelessWidget {
  ItemSwipe({
    required this.item,
  });

  //final String name;
  final Clothing item;

  void updateLaundry() {
    item.isLaundry = true;
    item.inLaundryFor = DateFormat.yMd().format(DateTime.now());
    item.upload();
  }

  @override
  Widget build(BuildContext context) {
    if (item.filename == "not") {
      return Padding(padding: EdgeInsets.only(left: 55.0, top: 160.0),
      child: Text("No more recommendation."));
    } else {
      return Swipable(
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.7,
          //padding: EdgeInsets.only(top: 50.0),
          decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                  image: NetworkImage(item.link!), fit: BoxFit.cover)),
        ),
        verticalSwipe: false,
        onSwipeLeft: (offset) => {},
        onSwipeRight: (offset) => {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Hooray, you choose to wear this today!"),
                  content: const Text(
                      "Do you want to add it to the laundry basket?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        updateLaundry();
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text("Yes please!"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text("No thanks"),
                    ),
                  ],
                );
              })
        },
      );
    }
  }
}
