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

  Future<List<Clothing>> download() async {
    List<Clothing> result = <Clothing>[];
    await FirebaseStorage.instance.ref().child('clothes/${widget.uid}/').listAll().then((res) async {
      for (var ref in res.items) {
        await ref.getDownloadURL().then((link) async {
          await ref.getMetadata().then((metadata) => {
            result.add(Clothing(widget.uid,
              link,
              metadata.customMetadata!['category']!,
              metadata.customMetadata!['sleeves']!,
              metadata.customMetadata!['color']!,
              metadata.customMetadata!['materials']!,
            ))
          });
        });
      }
    });
    return result;
  }
  List<Clothing> clothes = [];
  _ClosetState() {
    download().then((items) => {
      setState(() => {
        clothes = items
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    //final clothes = Provider.of<List<Clothing>?>(context) ?? [];

    if(clothes == null || clothes.isEmpty) {
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
                image: NetworkImage(clothes[index].imagePath),
              ),
            ),
            onTap: () => press(context),
          );
        }),
      )
    );
  }

  void press(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailPage(title: 'Placeholder'),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: const <Widget>[
          Text(
            'Category',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey
            ),
          ),
          Text(
            'Sleeve-type',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            ),
          ),
          Text(
            'Color',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            ),
          ),
          Text(
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
