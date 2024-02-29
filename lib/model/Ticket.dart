import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String attachment;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.attachment,
  });

  // Factory method to create a Ticket object from a Firestore document snapshot
  factory Ticket.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Ticket(
      id: snapshot.id,
      title: data['title'],
      description: data['description'],
      location: data['location'],
      date: data['date'].toDate(),
      attachment: data['attachment'],
    );
  }
}