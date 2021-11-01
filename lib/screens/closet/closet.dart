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

  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
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
            child: buildCloset(context, filterByTerms(searchController.text.split(" "), false))
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

bool Function(Clothing) filterByTerms(List<String> terms, bool isLaundry) {
  return (item) {
    for (String term in terms) {
      bool found = false;
      for (String result in item.category.split(" ")) {
        if (term == result) {
          found = true;
        }
      }
      for (String result in item.sleeves.split(" ")) {
        if (term == result) {
          found = true;
        }
      }
      for (String result in item.materials.split(" ")) {
        if (term == result) {
          found = true;
        }
      }
      for (String result in item.color.split(" ")) {
        if (term == result) {
          found = true;
        }
      }

      if (!found) {
        return false;
      }
    }
    return isLaundry == item.isLaundry;
  };
}
