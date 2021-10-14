import 'package:flutter/material.dart';
import '../../clothes.dart';

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