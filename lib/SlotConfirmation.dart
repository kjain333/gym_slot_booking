import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlotConfirmation extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SlotConfirmation();
  }
}
class _SlotConfirmation extends State<SlotConfirmation>{
  bool loading = true;
  String name,roll,image,email,date,slot;
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("booked", true);
    name = prefs.getString("name");
    roll = prefs.getString("roll");
    image = prefs.getString("image");
    email = prefs.getString("email");
    date = prefs.getString("date");
    slot = prefs.getString("slot");
    setState(() {
      loading = false;
    });
  }
  @override
  void initState() {
    fetchData();
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
                height: 70,
              ),
              Center(
                child: Icon(Icons.verified_rounded,color: Colors.green,size: 100,),
              ),
              SizedBox(
                height: 20,
              ),
              Text("SLOT CONFIRMATION",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text("Name: "+name,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16),),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text("Roll No.: "+roll,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16),),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text("Email: "+email,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16),),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text("Slot: "+slot,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16),),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text("Date: "+date,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 16),),
              ),
              SizedBox(
                height: 30,
              ),
              RaisedButton(
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        content: Image.network(image,fit: BoxFit.fill,),
                      );
                    }
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("View ID Image",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.white),),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        actions: [
                          GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("Yes",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),),
                            ),
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.remove("slot");
                              prefs.remove("date");
                              prefs.remove("booked");
                              SystemNavigator.pop();
                            },
                          ),
                          GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        content: Text("Make sure this button is only clicked by the security at the gym. Are you sure you want to confirm?",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300),),
                      );
                    }
                  );

                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Confirm Attendance",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: Colors.white),),
                ),
              )
            ],
          ),
        ),
    );
  }

}