import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import '../detail.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

class Laundry extends StatefulWidget {
  const Laundry({Key? key}) : super(key: key);

  @override
  State<Laundry> createState() => _LaundryState();
}

class _LaundryState extends State<Laundry> {
  bool _showConfDialog = true;
  int _selectedClothes = 0;
  final controller = DragSelectGridViewController();

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

  void deleteSpecificClothes(BuildContext context, List<Clothing> clothes) {
    showDialog(
        context: context,
        builder: (BuildContext cxt) {
          return AlertDialog(
            title: const Text("Please Confirm"),
            content: const Text("Are you sure you want to remove these clothes from the laundry basket?"),
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
                      if (clothes[index].isSelected) {
                        clothes[index].isLaundry = false;
                        clothes[index].inLaundryFor = '';
                        clothes[index].isSelected = false;
                        clothes[index].upload();
                      }
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox (height: 30),
                          Row(
                            children: <Widget>[
                              ElevatedButton(
                                    onPressed:
                          (_showConfDialog == true) ? () => ((_selectedClothes == 0) ? delete(context, laundryClothes) : deleteSpecificClothes(context, laundryClothes)) : null,
                          child: Text(
                          ((_selectedClothes > 0) ? 'Remove from Laundry Basket' : 'Empty Laundry Basket'),
                          style: TextStyle(
                          fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          )
                          ),
                          )


                          ],
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
                                                  image: NetworkImage(laundryClothes[index].link!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: (laundryClothes[index].isSelected) ? const Text('Selected',
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
                                            /*Image(
                                              image: NetworkImage(laundryClothes[index].link!),
                                              fit: BoxFit.cover,
                                            ),*/
                                          ))),
                                  onTap: () => {
                                    //press(context, laundryClothes[index])
                                    if (laundryClothes[index].isSelected) {
                                      setState(() {
                                        laundryClothes[index].isSelected = false;
                                        laundryClothes[index].upload();
                                        _selectedClothes--;
                                      })
                                    }
                                    else if (_selectedClothes > 0) {
                                      setState(() {
                                        laundryClothes[index].isSelected = true;
                                        laundryClothes[index].upload();
                                      })
                                    }
                                    else {
                                      press(context, laundryClothes[index])
                                    }
                                },
                                onLongPress: () => {
                                  setState(() {
                                    laundryClothes[index].isSelected = true;
                                    laundryClothes[index].upload();
                                    _selectedClothes++;
                                  }),
                                }
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