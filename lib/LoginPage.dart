import 'dart:convert';

import 'package:aad_oauth/model/config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gym_slot_booking/SlotBook.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static final Config config = Config(
      tenant: "850aa78d-94e1-4bc6-9cf3-8c11b530701c",
      clientId: "830d0aa4-32ae-4c83-9a4b-acf4e970d248",
      scope: "user.read openid profile offline_access",
      redirectUri: "https://login.live.com/oauth20_desktop.srf",);

  static String id = 'login_screen';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool login = false;
  bool picture = false;
  bool loading = false;
  final AadOAuth oauth = AadOAuth(LoginPage.config);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (loading)?Center(
        child: CircularProgressIndicator(),
      ):SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text("GYM SLOT BOOKING PORTAL",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.red),),
            Container(
              padding: EdgeInsets.all(20),
              child: Text("Terms and Conditions:\n\n1) The portal for a particular slot will open only 30 minutes prior to the slot.\n\n2) Please carry your id cards along for verification before entering the gym.\n\n3) Maintain proper social distancing inside the gym.\n\n4) Masks are compulsory\n\n5) Please show the guard the confirmation message you receive after slot confirmation.\n\n6) The confirm attendance button has to be used by gaurd at gym only otherwise you will loose your booking.",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
            ),
            ListTile(
              onTap: () async {
                setState(() {
                  loading = true;
                });
                try{
                  await oauth.login();
                }catch(err){
                  print(err);
                  Fluttertoast.showToast(msg: "Please allow permission");
                  setState(() {
                    loading = false;
                  });
                };
                String accessToken = await oauth.getAccessToken();
                String idToken = await oauth.getIdToken();
                if (accessToken!=null&&idToken!=null) {
                  var response = await http.get(
                      'https://graph.microsoft.com/v1.0/me',
                      headers: {HttpHeaders.authorizationHeader: accessToken});
                  var data = jsonDecode(response.body);
                  print(data['displayName']);
                  print(data['surname']);
                  await _auth.createUserWithEmailAndPassword(email: data['mail'], password: (data['surname']==null||(data['surname']!=null&&data['surname'].length<=6))?data['mail']:data['surname']).catchError((err){
                    print(err);
                    _auth.signInWithEmailAndPassword(email: data['mail'], password: (data['surname']==null||(data['surname']!=null&&data['surname'].length<=6))?data['mail']:data['surname']);
                  });
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("name", data['displayName']);
                  prefs.setString("roll", (data['surname']==null)?data['mail']:data['surname']);
                  prefs.setString("email",data['mail']);
                  setState(() {
                    login = true;
                    loading = false;
                  });
                } else{
                  setState(() {
                    loading = false;
                  });
                  Fluttertoast.showToast(msg: "Login failed! Please try again later.");
                }
              },
              title: Text("LOGIN with IITG EMAIL"),
              trailing: (login)?Icon(Icons.check_box,color: Colors.red,):Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              onTap: () async {
                setState(() {
                  loading = true;
                });
                PermissionStatus data = PermissionStatus.granted;
                if(Platform.isAndroid||Platform.isIOS)
                  {
                    data = await Permission.storage.request();
                    print(data);
                  }
                if(data==PermissionStatus.denied)
                  {
                    Fluttertoast.showToast(msg: "Please allow permission");
                    setState(() {
                      loading = false;
                    });
                  }
                else
                  {
                    if(login==false)
                    {
                      setState(() {
                        loading = false;
                      });
                      Fluttertoast.showToast(msg: "Please login first before uploading id card picture");
                    }
                    else
                    {
                      String image = await sendDocument(_auth.currentUser.uid);
                      if(image==null)
                      {
                        Fluttertoast.showToast(msg: "Image not uploaded! Please try again");
                        setState(() {
                          loading = false;
                        });
                      }
                      else
                      {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString("image", image);
                        setState(() {
                          picture = true;
                          loading = false;
                        });
                      }

                    }
                  }
              },
              title: Text("UPLOAD PICTURE of ID CARD"),
              trailing: (picture)?Icon(Icons.check_box,color: Colors.red,):Icon(Icons.arrow_forward_ios),
            ),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
              onPressed: () async {
                if(login==true&&picture==true)
                  {
                    //login, image, name, roll, email
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool("login",true);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SlotBook()));
                  }
                else
                  {
                      Fluttertoast.showToast(msg: "Please login and upload picture of id card to continue");
                  }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text("Proceed to slot Confirmation",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.white),),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text("Developed By:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300),),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/logo_sportsboard.jpg")
                )
              ),
            ),
            Text("Sports Board, IIT Guwahati",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300),),
            SizedBox(
              height: 20,
            )
          ],
        ),
      )
    );
  }
}
Future<String> sendDocument(String id) async {
  File documentToUpload = await documentSender();
  if (documentToUpload == null)
    return null;
  else {
    String message = await uploadFile(id, documentToUpload);
    if (message == null)
      return null;
    else {
      return message;
    }
  }
}

Future<File> documentSender() {
  return FilePicker.getFile(type: FileType.image);
}

Future<String> uploadFile(id, documentFile) async {
  String imageUrl;
  String fileName = id + DateTime.now().millisecondsSinceEpoch.toString();
  Reference reference = FirebaseStorage.instance.ref().child("gymSlot").child(fileName);
  await reference.putFile(documentFile).then((storageTaskSnapshot) async {
    await storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      print(downloadUrl);
    }, onError: (err) {
      print(err.toString());
    });
  }, onError: (err) {
    print("error");
  });
  return imageUrl;
}