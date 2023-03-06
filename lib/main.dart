import 'package:cloudgallery/providers/cloud_state_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'Views/cloud.dart';
import 'package:flutter/material.dart';
import 'Views/home.dart';
import 'Views/local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      ChangeNotifierProvider<CloudStateProvider>(
        create: (_) => CloudStateProvider(),
        child: const MyApp(),
      ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (_) => const MyHomePage(),
        "/local": (BuildContext context) => const Local(),
        "/cloud": (BuildContext context) => const Cloud(),
      },
    );
  }
}
