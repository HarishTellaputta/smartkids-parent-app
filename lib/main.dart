import 'package:flutter/material.dart';
import 'features/auth/login/login_screen.dart';

void main() {
  runApp(const ParentApp());
}


class ParentApp extends StatelessWidget {

  const ParentApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Smart School",

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const LoginScreen(),

    );
  }
}