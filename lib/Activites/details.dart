import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> activityDetails;

  ActivityDetailsScreen(this.activityDetails);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 134, 4, 163),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 225, 136, 245), Color.fromARGB(255, 160, 35, 227)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      activityDetails['titre'],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blue),
                      title: Text(
                        'Lieu: ${activityDetails['lieu']}',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.attach_money, color: Colors.green),
                      title: Text(
                        'Prix: \$${activityDetails['prix']}',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.people, color: Colors.orange),
                      title: Text(
                        'Nombre Minimum: ${activityDetails['nombreMinimum']}',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.category, color: Colors.purple),
                      title: Text(
                        'Catégorie: ${activityDetails['categorie']}',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.date_range, color: Colors.red),
                      title: Text(
                        'Date de création: ${_formatDate(activityDetails['createAt'])}',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Display the activity image
                    activityDetails['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              activityDetails['image'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(), // Placeholder if no image available
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }
}
