import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../service/database.dart';
import '../../clothes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Closet extends StatefulWidget {
  final String uid;
  const Closet({Key? key, required this.uid}) : super(key: key);

  @override
  State<Closet> createState() => _ClosetState();
}

class _ClosetState extends State<Closet> {
  List<Clothing> clothes = [];

  _ClosetState() {
    download().then((items) => {
      setState(() => {
        clothes = items
      })
    });
  }

  Future<List<Clothing>> download() async {
    List<Clothing> result = <Clothing>[];
    await FirebaseStorage.instance.ref().child('clothes/eqvoYX1qLAM4L2eJd9m34UDxSM82/').listAll().then((res) async {
      for (var ref in res.items) {
        await ref.getDownloadURL().then((link) async {
          await ref.getMetadata().then((metadata) {
            result.add(Clothing.usingLink(widget.uid,
              link,
              metadata.customMetadata!['category']!,
              metadata.customMetadata!['sleeves']!,
              metadata.customMetadata!['color']!,
              metadata.customMetadata!['materials']!,
            ));
          });
        });
      }
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    //final clothes = Provider.of<List<Clothing>?>(context) ?? [];

    if(clothes.isEmpty) {
      return const Center(
        child: Text("Oops you don't have anything in here yet. "
            "Click the plus button to add more items.",
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scaffold(
      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(clothes.length, (index) {
          return InkWell(
            child: Card(
              child: Image (
                image: NetworkImage(clothes[index].link!),
                fit: BoxFit.cover,
              ),
            ),
            onTap: () => press(context, clothes[index]),
          );
        }),
      )
    );
  }

  void press(BuildContext context, Clothing clothing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: 'Placeholder', clothing: clothing),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.title, required this.clothing}) : super(key: key);

  final String title;
  final Clothing clothing;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Clothing? clothing;

  _DetailPageState() {
    clothing = widget.clothing;
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
          Image (
            image: NetworkImage(widget.clothing.link!),
          ),
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey
            ),
          ),
          const Text(
            'Sleeve-type',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            ),
          ),
          const Text(
            'Color',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            ),
          ),
          const Text(
            'Materials',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            ),
          ),
        ],
      ),
    );
  }
}
