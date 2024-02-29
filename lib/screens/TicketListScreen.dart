import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:t2/model/Ticket.dart';
import 'package:ticket_widget/ticket_widget.dart';
import '../provider/TicketProvider.dart';
import 'TicketCreation.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  _TicketListScreen createState() => _TicketListScreen();
}

class _TicketListScreen extends ConsumerState<TicketListScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed---------');
        ref.refresh(ticketsProvider);
        break;
      case AppLifecycleState.paused:
        print('App minimised or Screen locked---------');
        break;
      case AppLifecycleState.detached:
        print('detach---------');
      case AppLifecycleState.inactive:
        print('inactive---------');
      case AppLifecycleState.hidden:
        print('hidden---------');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsyncValue = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Ticket (Thiran Task Two)'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reload ticket list data
          ref.refresh(ticketsProvider);
        },
        child: ticketsAsyncValue.when(
          data: (tickets) {
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                // return ListTile(
                //   title: Text('Title : '+ticket.title),
                //   subtitle: Text('Description '+ticket.description),
                //   // Display other ticket information here
                // );
                return TicketWidget(
                  width: 350,
                  height: 500,
                  isCornerRounded: true,
                  padding: EdgeInsets.all(20),
                  child: TicketData(ticket: tickets[index],),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TicketCreationScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  const TicketData({
    Key? key,
    required this.ticket,
  }) : super(key: key);

   final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
             children: [
               Text("Ticket ID"),
               Container(
                 width: 140.0,
                 height: 25.0,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(30.0),
                   border: Border.all(width: 1.0, color: Colors.green),
                 ),
                 child:  Center(
                   child: Text(
                     '#'+ticket.id,
                     style: TextStyle(color: Colors.green,fontSize: 9.0),
                   ),
                 ),
               ),
             ],
            ),
             Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.pink,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    DateFormat('yyyy-MM-dd – hh:mm').format(ticket.date),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),

         Padding(
          padding: EdgeInsets.only(top: 20.0),
          child:
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   ticket.title,
                   style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
                 ),
                 Row(
                   children: [
                     Padding(
                       padding: EdgeInsets.only(left: 8.0),
                       child: Icon(
                         Icons.location_pin,
                         color: Colors.pink,
                       ),
                     ),
                     Padding(
                       padding: EdgeInsets.only(left: 8.0),
                       child: Text(
                         ticket.location,
                         style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                       ),
                     )
                   ],
                 )
               ],
             )
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Text("Description : "+ticket.description)
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              image:  DecorationImage(
                image: NetworkImage(ticket.attachment==""?'https://cdn-icons-png.flaticon.com/512/4503/4503941.png':ticket.attachment),
                fit: BoxFit.contain,
              ),
              border: Border.all(
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          )
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}