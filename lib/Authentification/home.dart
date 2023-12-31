import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recognizeme_ia/Activites/Create.dart';
import 'package:recognizeme_ia/Activites/details.dart';
import 'package:recognizeme_ia/profile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'all';

  void _logout() async {
    await _auth.signOut();
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.home, color: Colors.white),
        title: Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 134, 4, 163),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 225, 136, 245), Color.fromARGB(255, 160, 35, 227)],
          ),
        ),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton('All', Icons.category),
                  _buildCategoryButton('Acting', Icons.theater_comedy),
                  _buildCategoryButton('Board Games', Icons.games),
                  _buildCategoryButton('Driving', Icons.directions_car),
                  _buildCategoryButton('Foods', Icons.fastfood),
                  _buildCategoryButton('Shopping', Icons.shopping_cart),
                  _buildCategoryButton('Sports', Icons.sports),
                  _buildCategoryButton('Videogames', Icons.videogame_asset),
                  _buildCategoryButton('Watching Movies', Icons.movie),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('activite').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var activities = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .where((activity) {
                    var category = activity['categorie'].trim() ?? '';
                    return selectedCategory == 'all' || category == selectedCategory;
                  }).toList();

                  return ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      var activity = activities[index];
                      var imageUrl = activity['image'] ?? '';
                      var category = activity['categorie'] ?? '';

                      return _buildActivityCard(activity, imageUrl, category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
bottomNavigationBar: BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Acceuil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add),
      label: 'Ajouter',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ],
  onTap: (int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateActivityScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  },
  selectedItemColor: Color.fromARGB(255, 134, 4, 163),
  unselectedItemColor: Colors.grey,
  backgroundColor: Colors.white,
  elevation: 4.0,
),
    );
  }

  ElevatedButton _buildCategoryButton(String category, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _filterByCategory(category.toLowerCase()),
      icon: Icon(icon),
      label: Text(category),
    );
  }

  Card _buildActivityCard(Map<String, dynamic> activity, String imageUrl, String category) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Container(height: 200, color: Colors.grey),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['titre'] ?? 'No title available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  activity['lieu'] ?? 'No location available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "\$${activity['prix'] ?? 'No price available'}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text(category),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailsScreen(activity),
                    ),
                  );
                },
                child: Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
