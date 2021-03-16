import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gym_slot_booking/SlotConfirmation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlotBook extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SlotBook();
  }
}
List<String> slots = ["6:00 - 7:00","7:00 - 8:00","8:00 - 9:00","15:00 - 16:00","16:00 - 17:00","17:00 - 18:00","18:00 - 19:00","19:00 - 20:00","20:00 - 21:00","21:00 - 22:00"];
class _SlotBook extends State<SlotBook>{
  int available = -1;
  int seatLeft = 0;
  bool loading = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> addData() async {
    CollectionReference slot = FirebaseFirestore.instance.collection('gymSlots');
    DateTime time = DateTime.now();
    String dataString = time.day.toString()+time.month.toString()+time.year.toString();
    int flag=0;
    for(int i=0;i<10;i++)
      {
        String temp = dataString + i.toString();
        DocumentReference dr = slot.doc(temp);
        if(dr!=null)
          {
            DocumentSnapshot ds = await dr.get();
            if(ds!=null&&ds.data()!=null&&ds.data().containsKey("users"))
              {
                if(ds.get("users").contains(auth.currentUser.uid))
                {
                  Fluttertoast.showToast(msg: "Cannot rebook a slot");
                  flag = 1;
                  break;
                }
              }
          }
      }
    if(flag==0)
      {
        dataString = dataString + available.toString();
        DocumentReference documentReference = slot.doc(dataString);
        DocumentSnapshot bookedSlots = await documentReference.get();
        if(bookedSlots.data()!=null && bookedSlots.data().containsKey("users"))
        {
          if(bookedSlots.get("users").length>=15)
          {
            Fluttertoast.showToast(msg: "Sorry slots have been filled!");
          }
          else if(bookedSlots.get("users").contains(auth.currentUser.uid))
          {
            Fluttertoast.showToast(msg: "Cannot rebook a slot");
          }
          else
          {
            documentReference.update({
              "users": FieldValue.arrayUnion([auth.currentUser.uid])
            });
            String date = time.day.toString()+"/"+time.month.toString()+"/"+time.year.toString();
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.setString("slot", slots[available]);
            sharedPreferences.setString("date", date);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SlotConfirmation()));
          }
        }
        else
        {
          documentReference.set({
            "users": FieldValue.arrayUnion([auth.currentUser.uid])
          });
          String date = time.day.toString()+"/"+time.month.toString()+"/"+time.year.toString();
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString("slot", slots[available]);
          sharedPreferences.setString("date", date);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SlotConfirmation()));
        }
      }

    setState(() {
      loading = false;
    });
  }
  Future<void> fetchData() async {
    DateTime time = DateTime.now();
    print(time.toString());
    if(time.hour==5&&time.minute>=30)
      {
        available = 0;
      }
    else if(time.hour==6&&time.minute>=30)
      {
        available = 1;
      }
    else if(time.hour==7&&time.minute>=30)
    {
      available = 2;
    }
    else if(time.hour==14&&time.minute>=30)
    {
      available = 3;
    }
    else if(time.hour==15&&time.minute>=30)
    {
      available = 4;
    }
    else if(time.hour==16&&time.minute>=30)
    {
      available = 5;
    }
    else if(time.hour==17&&time.minute>=30)
    {
      available = 6;
    }
    else if(time.hour==18&&time.minute>=30)
    {
      available = 7;
    }
    else if(time.hour==19&&time.minute>=30)
    {
      available = 8;
    }
    else if(time.hour==20&&time.minute>=30)
    {
      available = 9;
    }
    CollectionReference slot = FirebaseFirestore.instance.collection('gymSlots');
    String dataString = time.day.toString()+time.month.toString()+time.year.toString()+available.toString();
    DocumentReference documentReference = slot.doc(dataString);
    DocumentSnapshot bookedSlots = await documentReference.get();
    if(bookedSlots.data()!=null && bookedSlots.data().containsKey("users"))
      {
        seatLeft = 15 - bookedSlots.get("users").length;
      }
    else
      {
        seatLeft = 15;
      }
    setState(() {
      loading = false;
    });
  }
  bool clicked = false;
  @override
  void initState() {
    fetchData();
    Timer.periodic(Duration(minutes: 5), (timer) {
      fetchData();
    });
    super.initState();
  }
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
              Text("CHOOSE A SLOT",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text("Total seats left for available slot are: "+seatLeft.toString(),style: TextStyle(fontSize: 16,color: Colors.red,fontWeight: FontWeight.w500),),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: slots.map((e){
                  return ListTile(
                    enabled: (available==slots.indexOf(e)),
                    title: Text(e,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16),),
                    trailing: (available==slots.indexOf(e))?GestureDetector(
                      child: (clicked)?Icon(Icons.check_box,size: 24,color: Colors.red,):Icon(Icons.check_box_outline_blank,size: 24,color: Colors.red,),
                      onTap: (){
                        setState(() {
                          clicked = !clicked;
                        });
                      },
                    ):null,
                  );
                }).toList(),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: (){
                  if(seatLeft>0&&available!=-1)
                    {
                      setState(() {
                        loading = true;
                      });
                      addData();
                    }
                  else
                    {
                      Fluttertoast.showToast(msg: "Cannot book this slot!");
                    }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Book Slot",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.white),),
                ),
              )
            ],
          ),
        ),
    );
  }
}