import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:recognizeme_ia/profile.dart';
import 'package:recognizeme_ia/Authentification/home.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({Key? key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  TextEditingController titreController = TextEditingController();
  TextEditingController lieuController = TextEditingController();
  TextEditingController prixController = TextEditingController();
  TextEditingController nombreMinimumController = TextEditingController();

  File? _imageFile;
  List? _identifieResult;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    loadEmojiModel();
  }

  Future selectImage() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery, maxHeight: 300);
    identifyImage(image);
  }

  Future loadEmojiModel() async {
    Tflite.close();
    String categorie;
    categorie = (await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    ))!;
    print(categorie);
  }

  Future identifyImage(image) async {
    _identifieResult = null;
    final List? categorie = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        _identifieResult = categorie;
      } else {
        print('Aucune image sélectionnée.');
      }
    });
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName = Path.basename(imageFile.path);
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une activité', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 134, 4, 163),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titreController,
              decoration: InputDecoration(
                labelText: 'Titre',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: lieuController,
              decoration: InputDecoration(
                labelText: 'Lieu',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: prixController,
              decoration: InputDecoration(
                labelText: 'Prix',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: nombreMinimumController,
              decoration: InputDecoration(
                labelText: 'Nombre minimum',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                children: _identifieResult != null && _identifieResult!.isNotEmpty
                    ? _identifieResult!.map((result) {
                        String label = result["label"].toString().replaceAll(RegExp(r'[0-9]'), '');
                        return Text(
                          "Catégorie : $label",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      }).toList()
                    : [],
              ),
            ),
            (_imageFile != null)
                ? Image.file(_imageFile!)
                : Image.network('https://i.imgur.com/sUFH1Aq.png'),
            SizedBox(height: 20),
            FloatingActionButton(
              tooltip: 'Sélectionner une image',
              onPressed: () {
                selectImage();
              },
              child: Icon(
                Icons.add_a_photo,
                size: 25,
                color: Colors.purple, // Set color to purple
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var titre = titreController.text.trim();
                var lieu = lieuController.text.trim();
                var prix = prixController.text.trim();
                var nombreMinimum = nombreMinimumController.text.trim();

                if (titre.isNotEmpty && lieu.isNotEmpty && prix.isNotEmpty && nombreMinimum.isNotEmpty) {
                  try {
                    if (_imageFile != null) {
                      _uploadedImageUrl = await uploadImageToFirebase(_imageFile!);
                    }

                    String category = '';
                    if (_identifieResult != null && _identifieResult!.isNotEmpty) {
                      category = _identifieResult![0]["label"].toString().replaceAll(RegExp(r'[0-9]'), '');
                    }

                    await FirebaseFirestore.instance.collection("activite").doc().set({
                      "createAt": DateTime.now(),
                      "titre": titre,
                      "lieu": lieu,
                      "prix": prix,
                      "nombreMinimum": nombreMinimum,
                      "image": _uploadedImageUrl,
                      "categorie": category,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Activité ajoutée avec succès !"),
                      ),
                    );

                    titreController.clear();
                    lieuController.clear();
                    prixController.clear();
                    nombreMinimumController.clear();
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur lors de l'ajout de l'activité : $e"),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez remplir tous les champs et sélectionner une image."),
                    ),
                  );
                }
              },
              child: Text("Ajouter une activité"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Color.fromARGB(255, 134, 4, 163)),
            label: 'Ajouter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          } else if (index == 1) {
            // Gérer la navigation Ajouter

          } else if (index == 2) {
            // Gérer la navigation Profil
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
}
