import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import '../detail.dart';

class Laundry extends StatefulWidget {
  const Laundry({Key? key}) : super(key: key);

  @override
  State<Laundry> createState() => _LaundryState();
}

class _LaundryState extends State<Laundry> {
  void press(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailPage(clothing: clothing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    return StreamBuilder<List<Clothing>>(
        stream: DatabaseService(uid: user!.uid).closet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Clothing>? clothes = snapshot.data;
            List<Clothing> laundryClothes = [];

            if (clothes == null || clothes.isEmpty) {
              return const Center(
                child: Text(
                  "Oops you don't have anything in here yet. "
                      "Add clothes to the laundry basket from the closet screen.",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              for (int index = 0; index < clothes.length; index++) {
                if (clothes[index].isLaundry) {
                  laundryClothes.add(clothes[index]);
                }
              }
              return Scaffold(
                  body: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 2,
                    // Generate 100 widgets that display their index in the List.
                    children: List.generate(laundryClothes.length, (index) {
                      return InkWell(
                        child: Card(
                          child: Image(
                            image: NetworkImage(laundryClothes[index].link!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () => press(context, laundryClothes[index]),
                      );
                    }),
                  ));
            }
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}