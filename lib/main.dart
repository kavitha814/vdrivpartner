import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/professional_info.dart';
import 'screens/login.dart';
import 'screens/permanent_home.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VDrive Partner',
      theme: ThemeData(
       primaryColor: const Color(0xFFFFD300)  ,
      ),
      
      home: LoginScreen(),
    );
  }
  
}
