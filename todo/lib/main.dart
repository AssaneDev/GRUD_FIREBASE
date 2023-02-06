import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() => runApp(const InitializeApp());

class InitializeApp extends StatelessWidget {
  const InitializeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firestore todo",
      home: Scaffold(
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const ErrorFirebase();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return MyApp();
            }
            return const Loading();
          },
          future: Firebase.initializeApp(),
        ),
      ),
    );
  }
}

class ErrorFirebase extends StatelessWidget {
  const ErrorFirebase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firestore todo",
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text('Erreur de Chargement des données...'),
          ),
        ),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firestore todo",
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text('Chargement...'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final databaseReference = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firestore todo",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo Firebase'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            FormSection(),
            Expanded(
              child: ListSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class ListSection extends StatelessWidget {
  ListSection({Key? key}) : super(key: key);
  final databaseReference = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.collection('items').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return ListView(
          children: snapshot.data!.docs.map((document) {
            return CheckboxListTile(
              title: Text(
                document['text'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(document['time']),
              value: document['done'],
              activeColor: Colors.amber,
              secondary: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.withOpacity(0.6),
                ),
                onPressed: () {
                  deleteItem(document.id);
                },
              ),
              onChanged: (bool? value) {
                print(value);
                updateItem(document.id, value!);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void deleteItem(String itemID) {
    databaseReference.collection("items").doc(itemID).delete();
  }

  void updateItem(String itemID, bool itemDone) {
    databaseReference
        .collection("items")
        .doc(itemID)
        .update({"done": itemDone});
  }
}

class FormSection extends StatelessWidget {
  FormSection({Key? key}) : super(key: key);

  final databaseReference = FirebaseFirestore.instance;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: myController,
              decoration: const InputDecoration(
                hintText: 'Entrez une tache',
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () {
              addItem();
            },
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void addItem() {
    try {
      var now = DateTime.now();
      var hourAndMinutes = DateFormat('HH:mm');
      databaseReference.collection("items").add({
        "text": myController.text,
        "time": hourAndMinutes.format(now),
        "done": false
      }).then((value) {
        print(value.id);
        myController.clear();
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
