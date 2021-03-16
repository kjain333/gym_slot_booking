
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_slot_booking/LoginPage.dart';
import 'package:gym_slot_booking/SlotBook.dart';
import 'package:gym_slot_booking/SlotConfirmation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool data = false;
  bool data1 = false;
  if(prefs.containsKey("booked")&&prefs.get("booked")==true)
    data = true;
  if(prefs.containsKey("login")&&prefs.get("login")==true)
    data1 = true;
  runApp(MyApp(data,data1));
}

class MyApp extends StatelessWidget {
  bool data,data1;
  FirebaseAuth auth = FirebaseAuth.instance;
  MyApp(this.data,this.data1);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: (!data1)?LoginPage():(data)?SlotConfirmation():SlotBook(),
    );
  }
}
