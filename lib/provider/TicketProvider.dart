import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import '../model/Ticket.dart';

final ticketProvider = Provider((ref) => TicketRepository());

final ticketsProvider = FutureProvider<List<Ticket>>((ref) async {
  final querySnapshot = await FirebaseFirestore.instance.collection('tickets').get();
  return querySnapshot.docs.map((doc) => Ticket.fromSnapshot(doc)).toList();
});

class TicketRepository {
  // Function to store a ticket in Firestore
  Future<void> storeTicket(Ticket ticket) async {
    await FirebaseFirestore.instance.collection('tickets').add({
      'title': ticket.title,
      'description': ticket.description,
      'location': ticket.location,
      'date': ticket.date,
      'attachment': ticket.attachment,
    });

    // Send push notification after a minute
    Future.delayed(Duration(minutes: 1), () {
      sendPushNotification();
    });
    //sendPushNotification();
  }

  // Function to send push notification
  Future<void> sendPushNotification() async {
    // Initialize Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get the device token
    String? token = await messaging.getToken();
    sendNotificationToUser(token!);
  }

  sendNotificationToUser(String token) async {
    //Our API Key
    var serverKey = 'AAAAkLAEtRM:APA91bFkR7iHtPArb-z_FH7r8PZZeFgMHHaoc0PtpOIq4lEVtbXh3h7CO0Uktaa_g7_OVqMqhRUzfL5poiuQwgrG7rqv4pYHfgXIJ7BEHioGfaP7BwspTnaC4eG_mHEy_tSVpllL3WVr';

    //Create Message with Notification Payload
    String constructFCMPayload(String token) {
      return jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body':
           "Your ticket has been created successfully.",
            'title': "Ticket Created",
          },
          'data': <String, dynamic>{'name': 'Ticket User'},
          'to': token
        },
      );
    }

    if (token.isEmpty) {
      return log('Unable to send FCM message, no token exists.');
    }

    try {
      //Send  Message
      http.Response response =
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: constructFCMPayload(token));

      log("status: ${response.statusCode} | Message Sent Successfully!");
    } catch (e) {
      log("error push notification $e");
    }
  }
}