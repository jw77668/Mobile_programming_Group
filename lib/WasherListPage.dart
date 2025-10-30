import 'package:flutter/material.dart';

class WasherListPage extends StatelessWidget {
  final List<String> washers = ['LG F15SQA 세탁기', 'LG F8VDP 세탁기', 'LG F4KDA 세탁기'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내 세탁기 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
          itemCount: washers.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewPage())),
              child: Card(
                child: Column(
                  children: [
                    Expanded(child: Container(color: Colors.grey[200])),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(washers[index]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}