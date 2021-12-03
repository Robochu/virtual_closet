import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _selectionMode = false;

  List<int> _selectedIndex = <int>[];

  void press(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(clothing: clothing),
      ),
    );
  }

  void delete(BuildContext context, List<Clothing> clothes, String message) {
    showDialog(
        context: context,
        builder: (BuildContext cxt) {
          return AlertDialog(
            title: const Text("Please Confirm"),
            content: Text(message),
            //Text("Are you sure you want to empty the laundry basket?"),
            actions: [
              // Yes button
              TextButton(
                  onPressed: () {
                    // Set laundry status of clothes to false to remove from basket
                    for (var item in clothes) {
                      item.isLaundry = false;
                      item.inLaundryFor =
                          DateFormat.yMd().format(DateTime.now());
                      item.upload();
                    }
                    _selectedIndex.clear();
                    _selectionMode = false;
                    // Close confirmation dialog box
                    Navigator.of(cxt).pop();
                  },
                  child: const Text('Yes')),
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
        });
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
                return Scaffold(
                    body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      const SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlinedButton(
                                child: Text(
                                    (_selectionMode) ? "Cancel" : "Select",
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                onPressed: () {
                                  setState(() {
                                    _selectionMode = !_selectionMode;
                                    _selectedIndex.clear();
                                  });
                                }),
                            TextButton(
                              onPressed: () {
                                if (_selectionMode &&
                                    _selectedIndex.isNotEmpty) {
                                  List<Clothing> toEmpty = <Clothing>[];
                                  for (var index in _selectedIndex) {
                                    toEmpty.add(laundryClothes[index]);
                                  }
                                  delete(context, toEmpty,
                                      "Are you sure you want to remove these clothes from the laundry basket?");
                                } else if (!_selectionMode) {
                                  delete(context, laundryClothes,
                                      "Are you sure you want to empty the laundry basket?");
                                }
                              },
                              child: Text(
                                  ((_selectionMode)
                                      ? 'Remove from Laundry Basket'
                                      : 'Empty Laundry Basket'),
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      (_selectionMode && _selectedIndex.isEmpty)
                                          ? Colors.black45
                                          : Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                          ]),
                      const SizedBox(height: 10),
                      Expanded(
                          child: GridView.count(
                        // Create a grid with 2 columns. If you change the scrollDirection to
                        // horizontal, this produces 2 rows.
                        crossAxisCount: 2,
                        // Generate 100 widgets that display their index in the List.
                        children: List.generate(laundryClothes.length, (index) {
                          if (_selectionMode) {
                            return GridTile(
                                header: GridTileBar(
                                    leading: Icon(
                                  _selectedIndex.contains(index)
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked_rounded,
                                  color: _selectedIndex.contains(index)
                                      ? Colors.blue
                                      : Colors.black,
                                  size: 30.0,
                                )),
                                child: InkWell(
                                    child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              constraints:
                                                  const BoxConstraints.expand(
                                                height: 200.0,
                                              ),
                                              alignment: Alignment.bottomLeft,
                                              padding: const EdgeInsets.only(
                                                  left: 16.0, bottom: 8.0),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      laundryClothes[index]
                                                          .link!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ))),
                                    onTap: () => {
                                          setState(() {
                                            if (_selectedIndex
                                                .contains(index)) {
                                              _selectedIndex.remove(index);
                                            } else {
                                              _selectedIndex.add(index);
                                            }
                                          })
                                        },
                                    onLongPress: () => {
                                          setState(() {
                                            _selectionMode = !_selectionMode;
                                          }),
                                        }));
                          } else {
                            return InkWell(
                                child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          constraints:
                                              const BoxConstraints.expand(
                                            height: 200.0,
                                          ),
                                          alignment: Alignment.bottomLeft,
                                          padding: const EdgeInsets.only(
                                              left: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  laundryClothes[index].link!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ))),
                                onTap: () =>
                                    {press(context, laundryClothes[index])},
                                onLongPress: () => {
                                      setState(() {
                                        _selectionMode = !_selectionMode;
                                      }),
                                    });
                          }
                        }),
                      ))
                    ]));
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
