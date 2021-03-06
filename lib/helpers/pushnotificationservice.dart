import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver/widgets/NotificationDialog.dart';
import 'package:driver/widgets/ProgressDialog.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


import 'package:driver/globalvariable.dart';
import 'package:driver/helpers/rideDetails.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService{


  final FirebaseMessaging fcm = FirebaseMessaging();


  Future initialize(context) async{


    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);

      },
      onLaunch: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);


      },
      onResume: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message), context);


      },
    );
  }
  
  Future <String> getToken() async{
    
    String token = await fcm.getToken();
    print('token: $token');
    
    DatabaseReference TokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
    TokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');
    
  }

  String getRideID(Map<String, dynamic> message){
    String rideID = '';
    if(Platform.isAndroid){
      rideID = message['data']['ride_id'];
      print('ride_id:$rideID');

    }

    return rideID;

  }
  
  void fetchRideInfo(String rideID, context)   {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Fetch Details ',),

    );

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child("rideRequest/$rideID");
    rideRef.once().then((DataSnapshot snapshot){

        Navigator.pop(context);

      if  (snapshot.value != null) {
        assetsAudioPlayer.open(
          Audio('sounds/alert.mp3'),
        );
        assetsAudioPlayer.play();



        double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat = double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng = double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress = snapshot.value['destination_address'].toString();
        String paymentMethod = snapshot.value['payment_method'].toString();
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        RideDetails rideDetails = RideDetails();
        rideDetails.rideID = rideID;
        rideDetails.pickup_address = pickupAddress;
        rideDetails.destination_address = destinationAddress;
        rideDetails.location = LatLng(pickupLat, pickupLng);
        rideDetails.destination = LatLng(destinationLat, destinationLng);
        rideDetails.payment_method = paymentMethod;
        rideDetails.riderName = riderName;
        rideDetails.riderPhone = riderPhone;

        print("INFO");
        print(rideDetails.pickup_address);
        print(rideDetails.destination_address);
        print(snapshot.value.toString());
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(rideDetails: rideDetails,),
        );


      }
      else
      {
        print("INFO");

      }



    });


  }


}