import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import '../detail.dart';

class Closet extends StatefulWidget {
  const Closet({Key? key, bool? isSelectable})
      : isSelectable = isSelectable ?? false;
  final bool isSelectable;

  @override
  State<Closet> createState() => _ClosetState();
}

class _ClosetState extends State<Closet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController searchController;
  late TextEditingController materialsController;
  late final bool _isSelectable;
  String categoryFilter = "";
  String sleevesFilter = "";
  String colorFilter = "";
  String itemFilter = "";
  String laundryFilter = "";
  List<int> _selectedIndex = <int>[];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    materialsController = TextEditingController();
    _isSelectable = widget.isSelectable;
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    materialsController.dispose();
  }

  void press(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(clothing: clothing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        appBar: const TabBar(
          isScrollable: true,
          indicatorColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.blue,
          tabs: [
            Tab(text: "All"),
            Tab(text: "Tops"),
            Tab(text: "Bottoms"),
            Tab(text: "Outerwear"),
            Tab(text: "Shoes"),
            Tab(text: "Accessories"),
            Tab(text: "Full Body"),
            Tab(icon: Icon(Icons.search)),
          ],
        ),
        body: TabBarView(
          children: [
            buildCloset(context, filterByCategory("All")),
            buildCloset(context, filterByCategory("Tops")),
            buildCloset(context, filterByCategory("Bottoms")),
            buildCloset(context, filterByCategory("Outerwear")),
            buildCloset(context, filterByCategory("Shoes")),
            buildCloset(context, filterByCategory("Accessories")),
            buildCloset(context, filterByCategory("Full Body")),
            buildSearch(context),
          ],
        ),
      ),
    );
  }

  Widget buildSearch(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              labelText: "Search",
            ),
            controller: searchController,
            onChanged: (text) => setState(() {}),
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        labelText: 'Category',
                      ),
                      isExpanded: true,
                      hint: const Text('Choose a category'),
                      value: categoryFilter,
                      onChanged: (text) => setState(() {
                        categoryFilter = text!;
                      }),
                      items: <String>[
                        '',
                        'Tops',
                        'Bottoms',
                        'Outerwear',
                        'Shoes',
                        'Accessories',
                        'Full Body'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        labelText: 'Clothing item',
                      ),
                      isExpanded: true,
                      hint: const Text('What exactly is it?'),
                      value: itemFilter,
                      onChanged: (text) => setState(() {
                        itemFilter = text!;
                      }),
                      items: <String>[
                        '',
                        'Hat',
                        'Jacket',
                        'Pants',
                        'Shoes',
                        'Shorts',
                        'Suit',
                        'T-shirt',
                        'Other'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        labelText: 'Color',
                      ),
                      isExpanded: true,
                      hint: const Text('Choose a color'),
                      value: colorFilter,
                      onChanged: (text) => setState(() {
                        colorFilter = text!;
                      }),
                      items: <String>[
                        '',
                        'Black',
                        'Blue',
                        'Brown',
                        'Grey',
                        'Green',
                        'Orange',
                        'Pink',
                        'Purple',
                        'Red',
                        'White',
                        'Yellow',
                        'Multicolor'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        labelText: 'Length',
                      ),
                      isExpanded: true,
                      hint: const Text('How long is it?'),
                      value: sleevesFilter,
                      onChanged: (text) => setState(() {
                        sleevesFilter = text!;
                      }),
                      items: <String>['', 'Short', 'Long', 'N/A']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: "Materials",
                      ),
                      controller: materialsController,
                      onChanged: (text) => setState(() {}),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        filled: true,
                        labelText: 'Laundry status',
                      ),
                      isExpanded: true,
                      hint: const Text('Is the item in laundry?'),
                      value: laundryFilter,
                      onChanged: (text) => setState(() {
                        laundryFilter = text!;
                      }),
                      items: <String>[
                        '',
                        'In closet',
                        'In laundry',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: buildCloset(
                context,
                filterByEverything(
                  searchController.text.split(" "),
                  categoryFilter,
                  sleevesFilter,
                  colorFilter,
                  materialsController.text.split(" "),
                  itemFilter,
                  laundryFilter.isEmpty ? null : laundryFilter == 'In laundry',
                )),
          ),
        ],
      ),
    );
  }

  Widget buildCloset(BuildContext context, bool Function(Clothing) filter) {
    final user = Provider.of<MyUser?>(context);
    return StreamBuilder<List<Clothing>>(
        stream: DatabaseService(uid: user!.uid).closet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Clothing>? clothes = snapshot.data;
            if (clothes != null) {
              bool empty = clothes.isEmpty;
              clothes = clothes.where(filter).toList();
              if (clothes.isEmpty) {
                return Center(
                  child: Text(
                    empty
                        ? "Oops you don't have anything in here yet. "
                            "Click the plus button to add more items."
                        : "No items found!",
                    textAlign: TextAlign.center,
                  ),
                );
              }
            }

            return Scaffold(
              floatingActionButton: (_selectedIndex.isNotEmpty)
                ? TextButton(child: Text("Done"), onPressed: (){
                  List<Clothing> selectedItems = <Clothing>[];
                  for(var index in _selectedIndex) {
                    selectedItems.add(clothes![index]);
                  }
                  Navigator.pop(context, selectedItems);
              })
                : Container(),
                body: GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 2,
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(clothes!.length, (index) {
                    if (_isSelectable) {
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
                                                clothes![index].link!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: (clothes[index].isLaundry)
                                            ? const Text('In Laundry',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                          blurRadius: 10.0,
                                                          color: Colors.black)
                                                    ]))
                                            : null,
                                      ))),
                              onTap: () {
                                if (_isSelectable) {
                                  setState(() {
                                    if (_selectedIndex.contains(index)) {
                                      _selectedIndex.remove(index);
                                    } else {
                                      _selectedIndex.add(index);
                                    }
                                  });
                                }
                              }));
                    } else {
                      return InkWell(
                          child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    constraints: const BoxConstraints.expand(
                                      height: 200.0,
                                    ),
                                    alignment: Alignment.bottomLeft,
                                    padding: const EdgeInsets.only(
                                        left: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(clothes![index].link!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: (clothes[index].isLaundry)
                                        ? const Text('In Laundry',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 10.0,
                                                      color: Colors.black)
                                                ]))
                                        : null,
                                  ))),
                          onTap: () {
                            press(context, clothes![index]);
                          });
                    }
                  }),
                ));
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

bool Function(Clothing) filterByCategory(String category) {
  return (item) => category == "All" || category == item.category;
}

bool Function(Clothing) filterByItem(String itemType) {
  return (item) => itemType == item.item;
}

bool Function(Clothing) filterByEverything(
    List<String> terms,
    String category,
    String sleeves,
    String color,
    List<String> materials,
    String type,
    bool? isLaundry) {
  return (item) {
    for (String term in terms) {
      if (!(item.category.toLowerCase().contains(term.toLowerCase()) ||
          item.sleeves.toLowerCase().contains(term.toLowerCase()) ||
          item.color.toLowerCase().contains(term.toLowerCase()) ||
          item.materials.toLowerCase().contains(term.toLowerCase()) ||
          item.item.toLowerCase().contains(term.toLowerCase()))) {
        return false;
      }
    }
    for (String term in materials) {
      if (!item.materials.toLowerCase().contains(term.toLowerCase())) {
        return false;
      }
    }
    return (category.isEmpty || category == item.category) &&
        (sleeves.isEmpty || sleeves == item.sleeves) &&
        (color.isEmpty || color == item.color) &&
        (type.isEmpty || type == item.item) &&
        (isLaundry == null || isLaundry == item.isLaundry);
  };
}
