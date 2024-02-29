import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../model/Ticket.dart';
import '../provider/TicketProvider.dart';

class NewTicket extends StatefulWidget {
  const NewTicket({super.key, required this.ref});
  final WidgetRef ref;

  @override
  State<NewTicket> createState() => _NewTicketState();
}

class _NewTicketState extends State<NewTicket> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  FirebaseStorage store = FirebaseStorage.instance;
  bool isLoading = false;
  String imagePath = '';

  @override
  void initState() {
    setState(() {
      _dateController.text = 'Date: ${DateTime.now()}';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Ticket')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Problem Title',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Problem Description',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a lo`';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      enabled: false,
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            isLoading = true;
                          });
                          var imageName = DateTime.now().millisecondsSinceEpoch.toString();
                          var storageRef = FirebaseStorage.instance.ref().child('driver_images/$imageName.jpg');
                          var uploadTask = storageRef.putData(await pickedImage.readAsBytes()!);
                          var downloadUrl = await (await uploadTask).ref.getDownloadURL();
                          setState(() {
                            imagePath = downloadUrl;
                            isLoading = false;
                          });
                          print(downloadUrl);
                        }
                      },
                      child: Center(
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image:  DecorationImage(
                                image: NetworkImage(imagePath==""?'https://cdn-icons-png.flaticon.com/512/4503/4503941.png':imagePath),
                                fit: BoxFit.contain,
                              ),
                              border: Border.all(
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 16),
                    // Date field should be auto-filled, you can use a Text widget to display the current date
                    // Attachment field can be added using TextFormField or any other appropriate widget
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final title = _titleController.text;
                            final description = _descriptionController.text;
                            final location = _locationController.text;
                            final date = DateTime.now(); // Auto-filled date
                            final attachment = imagePath; // Implement attachment logic

                            final ticket = Ticket(
                              id: '',
                              title: title,
                              description: description,
                              location: location,
                              date: date,
                              attachment: attachment,
                            );

                            // Store ticket in Firestore
                            await widget.ref.read(ticketProvider).storeTicket(ticket);

                            widget.ref.refresh(ticketsProvider);

                            setState(() {
                              isLoading = false;
                            });

                            // Show alert dialog after ticket is stored
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Ticket Created'),
                                  content: Text('Your ticket has been created.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        // Close the dialog and navigate back to ticket list screen
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text('Submit Ticket'),
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
          if (isLoading) Center(child: SpinKitWanderingCubes(
            color: Colors.black,
            size: 60.0,
          ),),
        ],
      )
    );
    ;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class TicketCreationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NewTicket(ref: ref);
  }
}
