import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/clothes.dart';
import 'dart:math' as math;
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/combinations/designer.dart';
import 'package:virtual_closet/service/database.dart';
import 'outfit.dart';

class Combo extends StatefulWidget {
  const Combo({Key? key}) : super(key: key);

  @override
  State<Combo> createState() => _ComboState();
}

class _ComboState extends State<Combo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();
  bool isChecked = true;

  @override
  void initState() {
    super.initState();
  }

  void press(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Designer(
                outfit: Outfit("", [], ''),
              ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery
                  .of(context)
                  .size
                  .width, 150.0 ),
              child: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.transparent,
                labelColor: Colors.black87,
                tabs: <Widget>[
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    child: const Text(""),
                  ),
                  Container(
                      child: const Icon(Icons.search, color: Colors.black87)),
                ],
              )),
          body: TabBarView(
            children: [
              buildOutfits(context, filterByName(null)),
              buildSearch(context),
            ],
          ),
        ));
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
          Row(
            children: [
              Checkbox(
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  }
              ),
              const Text("Search outfit name only.")
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child:
            isChecked
                ? buildOutfits(context, filterByName(searchController.text))
                : buildOutfits(
                context, filterByEverything(searchController.text.split(" "))),
          )
        ],
      ),
    );
  }

  Widget buildOutfits(BuildContext context, bool Function(Outfit) filter) {
    final user = Provider.of<MyUser?>(context, listen: false);
    return StreamBuilder<List<Outfit>>(
        stream: DatabaseService(uid: user!.uid).outfits,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Outfit>? outfits = snapshot.data;
            bool empty = false;
            if (outfits != null) {
              empty = outfits.isEmpty;
              outfits = outfits.where(filter).toList();
              if (outfits.isEmpty) {
                return Center(
                  child: Text(
                    empty ? "No outfits created." : "No outfits found!",
                    textAlign: TextAlign.center,
                  ),
                );
              }
            }
            return Column(children: [
              Center(
                  child: ElevatedButton(
                    onPressed: () => press(context),
                    child: const Text("Design an outfit",
                        style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  )),
              outfits!.isEmpty
                  ? const SizedBox(height: 50)
                  : const SizedBox(height: 20),
              outfits.isEmpty
                  ? Center(
                child: Text(
                  empty ? "No outfits created." : "No outfits found!",
                  textAlign: TextAlign.center,
                ),
              )
                  : Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      // Generate 100 widgets that display their index in the List.
                      children: List.generate(outfits.length, (index) {
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
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        //can't display preview image because query is not fast enough
                                          color: Color((math.Random()
                                              .nextDouble() *
                                              0xFFFFFF)
                                              .toInt())
                                              .withOpacity(1.0)),
                                      child: Text(
                                          (outfits![index].name == '')
                                              ? 'Outfit'
                                              : outfits[index].name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            /*
                                            shadows: [
                                              Shadow (
                                                  blurRadius: 10.0,
                                                  color: Colors.black
                                              )
                                            ]*/
                                          ))))),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Designer(
                                        outfit: outfits![index],
                                      ),
                                ));
                          },
                        );
                      })))
            ]);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  bool Function(Outfit) filterByName(String? name) {
    return (outfit) =>
    name == null || outfit.name.toLowerCase().contains(name.toLowerCase());
  }

  bool Function(Outfit) filterByEverything(List<String> terms) {
    bool match = false;

    return (outfit) {
      List<Clothing> clothing = [...outfit.clothes];
      for(var term in terms) {
        for (var item in clothing) {
          if (item.category.toLowerCase().contains(term.toLowerCase()) ||
              item.sleeves.toLowerCase().contains(term.toLowerCase()) ||
              item.color.toLowerCase().contains(term.toLowerCase()) ||
              item.materials.toLowerCase().contains(term.toLowerCase()) ||
              item.item.toLowerCase().contains(term.toLowerCase())) {
            match = true;
          }
        }
        match = outfit.name.toLowerCase().contains(term.toLowerCase()) || match;
      }
      return match;
    };
  }
}
