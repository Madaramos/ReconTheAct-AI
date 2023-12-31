import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recognizeme_ia/Authentification/home.dart';
import 'package:recognizeme_ia/Activites/Create.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _user;
  late TextEditingController _anniversaireController;
  late TextEditingController _adresseController;
  late TextEditingController _codePostalController;
  late TextEditingController _villeController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _anniversaireController = TextEditingController();
    _adresseController = TextEditingController();
    _codePostalController = TextEditingController();
    _villeController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUserData();
  }

  void _fetchUserData() {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      String userId = _user!.uid;

      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _anniversaireController.text = data['anniversaire'] ?? '';
            _adresseController.text = data['adresse'] ?? '';
            _codePostalController.text = data['codePostal'] ?? '';
            _villeController.text = data['ville'] ?? '';
            _emailController.text = _user!.email ?? '';
          });
        }
      });
    }
  }

  Widget _buildDataInput(IconData icon, String label, TextEditingController controller, String placeholder) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: placeholder,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateUserData() {
    if (_user != null) {
      String userId = _user!.uid;

      FirebaseFirestore.instance.collection('users').doc(userId).set({
        'anniversaire': _anniversaireController.text,
        'adresse': _adresseController.text,
        'codePostal': _codePostalController.text,
        'ville': _villeController.text,
        'email': _user!.email,
      }, SetOptions(merge: true)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data updated successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user data')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 134, 4, 163),
        title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),  // Navigate to Home
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDataInput(Icons.email, 'Email', _emailController, 'Enter your email'),
              _buildDataInput(Icons.cake_rounded, 'Anniversaire', _anniversaireController, 'Enter your birthday'),
              _buildDataInput(Icons.house, 'Adresse', _adresseController, 'Enter your address'),
              _buildDataInput(Icons.local_post_office, 'Code postal', _codePostalController, 'Enter your postal code'),
              _buildDataInput(Icons.location_city, 'Ville', _villeController, 'Enter your city'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateUserData,
        child: Icon(Icons.save),
        backgroundColor: Colors.purple,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Color.fromARGB(255, 134, 4, 163)),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,color: Color.fromARGB(255, 134, 4, 163)),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateActivityScreen()),
            );
          } else if (index == 2) {
          }
        },
        selectedItemColor: Color.fromARGB(255, 134, 4, 163),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 4.0,
      ),
    );
  }
}
