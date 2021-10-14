import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Closet extends StatefulWidget {
  const Closet({Key? key}) : super(key: key);

  @override
  State<Closet> createState() => _ClosetState();
}

class _ClosetState extends State<Closet> {
  void press(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailPage(title: 'Placeholder', clothing: clothing),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    return StreamBuilder<List<Clothing>>(
        stream: DatabaseService(uid: user!.uid).closet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Clothing>? clothes = snapshot.data;
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
                    child: Card(
                      child: Image(
                        image: NetworkImage(clothes[index].link!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () => press(context, clothes[index]),
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

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.title, required this.clothing})
      : super(key: key);

  final String title;
  final Clothing clothing;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Clothing? clothing;

  @override
  void initState() {
    super.initState();
    clothing = Clothing.clone(widget.clothing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Image(
            image: NetworkImage(widget.clothing.link!),
          ),
          const Text(
            'Category',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: clothing!.category,
              onChanged: (String? value) {
                setState(() {
                  clothing!.category = value!;
                });
              },
              items: <String>[
                'Tops',
                'Bottoms',
                'Outerwear',
                'Shoes',
                'Accessories'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Text(
            'Sleeve-type',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const Text(
            'Color',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const Text(
            'Materials',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () => {Navigator.pop(context)},
                ),
              ),
              Container(
                width: 10,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: const Text('Save'),
                  onPressed: clothing == widget.clothing
                      ? null
                      : () => {clothing!.upload()},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
