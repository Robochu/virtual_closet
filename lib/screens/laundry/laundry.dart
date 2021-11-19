import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import '../detail.dart';

class Laundry extends StatefulWidget {
  const Laundry({Key? key}) : super(key: key);

  @override
  State<Laundry> createState() => _LaundryState();
}

class _LaundryState extends State<Laundry> {
  bool _showConfDialog = true;

  void press(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(clothing: clothing),
      ),
    );
  }

  void delete(BuildContext context, List<Clothing> clothes) {
    showDialog(
        context: context,
        builder: (BuildContext cxt) {
          return AlertDialog(
            title: const Text("Please Confirm"),
            content: const Text("Are you sure you want to empty the laundry basket?"),
            actions: [
              // Yes button
              TextButton(
                  onPressed: () {
                    // Remove confirmation dialog from view
                    setState(() {
                      _showConfDialog = false;
                    });
                    // Set laundry status of clothes to false to remove from basket
                    for (int index = 0; index < clothes.length; index++) {
                      clothes[index].isLaundry = false;
                      clothes[index].inLaundryFor = '';
                      clothes[index].upload();
                    }
                    // Close confirmation dialog box
                    Navigator.of(cxt).pop();
                  },
                  child: const Text('Yes')
              ),
              // No button
              TextButton(
                onPressed: () {
                  // Close confirmation dialog box
                  Navigator.of(cxt).pop();
                },
                child: const Text('No'),
              ),
            ],
          );
        }
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
                  "Oops you don't have any clothes added to the closet yet.",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              // Store clothes with laundry status true in a list
              for (int index = 0; index < clothes.length; index++) {
                if (clothes[index].isLaundry) {
                  laundryClothes.add(clothes[index]);
                }
              }
              if (laundryClothes.isEmpty) {
                return const Center(
                  child: Text(
                    "The laundry basket is currently empty.\n\n"
                        "To add clothes here, change the laundry status from the closet screen.",
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                _showConfDialog = true;
                return Scaffold(
                    body: Column(
                        children: <Widget>[
                          const SizedBox (height: 30),
                          Center(
                              child: ElevatedButton(
                                onPressed: (_showConfDialog == true) ? () => delete(context, laundryClothes) : null,
                                child: const Text(
                                  'Empty Laundry Basket', style: TextStyle(
                                    fontSize: 20)),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  )
                                ),
                              )
                          ),
                          const SizedBox(height: 15),
                          Expanded(child: GridView.count(
                            // Create a grid with 2 columns. If you change the scrollDirection to
                            // horizontal, this produces 2 rows.
                            crossAxisCount: 2,
                            // Generate 100 widgets that display their index in the List.
                            children: List.generate(
                                laundryClothes.length, (index) {
                              return InkWell(
                                child: Padding (
                                    padding: EdgeInsets.all(15),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image(
                                        image: NetworkImage(laundryClothes[index].link!),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                onTap: () =>
                                    press(context, laundryClothes[index]),
                              );
                            }),
                          ))
                        ]
                    )
                );
              }
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