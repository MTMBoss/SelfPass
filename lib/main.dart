import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/web_account/web_account_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SelfPass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Homepage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/editAccount') {
          return MaterialPageRoute(
            builder: (context) => const WebAccountPage(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
