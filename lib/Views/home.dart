import 'package:cloudgallery/Views/cloud.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'local.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPage = 1;

  @override
  void initState() {
    super.initState();
    selectedPage = 1;
  }

  setPage() {
    if (selectedPage == 0){
      return const Local();
    } else {
      return const Cloud();
    }
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.flip,
        items: const [
          TabItem(icon: Icons.drive_folder_upload, title: 'Local'),
          TabItem(icon: Icons.cloud_download_outlined, title: 'Cloud'),
        ],
        initialActiveIndex: selectedPage,
        onTap: (int index) => setState(() {
          selectedPage = index;
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: setPage(),
          ),
        ],
      ),
    );
  }
}
