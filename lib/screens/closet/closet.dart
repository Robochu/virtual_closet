import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import '../detail.dart';

class Closet extends StatefulWidget {
  const Closet({Key? key}) : super(key: key);

  @override
  State<Closet> createState() => _ClosetState();
}

class _ClosetState extends State<Closet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController searchController;

  String categoryFilter = "";
  String sleevesFilter = "";
  String colorFilter = "";
  String materialsFilter = "";
  String itemFilter = "";

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

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
    return DefaultTabController(
      length: 7,
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
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    filled: true,
                    labelText: 'Category',
                  ),
                  isExpanded: true,
                  hint: const Text('Choose a category'),
                  value: categoryFilter,
                  onChanged: (text) => setState(() {}),
                  items: <String>[
                    '', 'Tops', 'Bottoms', 'Outerwear', 'Shoes', 'Accessories'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    filled: true,
                    labelText: 'Clothing item',
                  ),
                  isExpanded: true,
                  hint: const Text('What exactly is it?'),
                  value: itemFilter,
                  onChanged: (text) => setState(() {}),
                  items: <String>[
                    '', 'Hat', 'Jacket', 'Pants', 'Shoes', 'Shorts', 'Suit', 'T-shirt', 'Other'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: buildCloset(context, filterByEverything(
              searchController.text.split(" "),
              categoryFilter,
              sleevesFilter,
              colorFilter,
              materialsFilter,
              itemFilter,
              false,
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
              clothes = clothes.where(filter).toList();
            }

            if (clothes == null || clothes.isEmpty) {
              return const Center(
                child: Text(
                  "Oops you don't have anything in here yet. "
                      "Click the plus button to add more items.",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Scaffold(
                  body: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 2,
                    // Generate 100 widgets that display their index in the List.
                    children: List.generate(clothes.length, (index) {
                      return InkWell(
                        child: Padding (
                            padding: const EdgeInsets.all(15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image(
                                image: NetworkImage(clothes![index].link!),
                                fit: BoxFit.cover,
                              ),
                            )
                        ),
                        onTap: () => press(context, clothes![index]),
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

bool Function(Clothing) filterByCategory(String category) {
  return (item) => category == "All" || category == item.category;
}

bool Function(Clothing) filterByEverything(List<String> terms, String category,
  String sleeves, String color, String materials, String type, bool? isLaundry) {
  return (item) {
    for (String term in terms) {
      if (!(item.category.contains(term) || item.sleeves.contains(term) ||
        item.color.contains(term) || item.materials.contains(term) ||
        item.item.contains(term))) {
        return false;
      }
    }
    return (category.isEmpty || category == item.category) && (sleeves.isEmpty || sleeves == item.sleeves) && (color.isEmpty || color == item.color) && (materials.isEmpty || materials == item.materials) && (type.isEmpty || type == item.item) && isLaundry! == item.isLaundry;
  };
}
