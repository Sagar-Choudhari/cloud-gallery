import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  final String imgName;
  final String imgUrl;

  const ViewImage(this.imgName, this.imgUrl, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_backspace_rounded),
          ),
          title: Text(imgName),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Image.network(imgUrl),
        ),
      ),
    );
  }
}