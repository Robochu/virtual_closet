import 'package:flutter/material.dart';

import 'clothes.dart';

class Closet extends StatefulWidget {
  const Closet({Key? key}) : super(key: key);

  @override
  State<Closet> createState() => _ClosetState();
}

class _ClosetState extends State<Closet> {
  @override
  Widget build(BuildContext context) {
    List<Clothing> clothes = Clothing.download();
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
