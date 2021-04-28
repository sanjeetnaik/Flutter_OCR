import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Data extends StatelessWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var ls = [];

  createwidget(var lss) {
    List<Widget> lsofwidgets = [];
    for (int i = 0; i < ls.length; i++) {
      lsofwidgets.add(Text(lss[i]));
    }
    return lsofwidgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestore.collection("users").get(),
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          ls = [];
          final data = snapshot.data.docs;
          for (int i = 0; i < data.length; i++) {
            print(snapshot.data.docs[i].data()['data'].toString());
            ls.add(snapshot.data.docs[i].data()['data'].toString());
          }
        }
        var abc = snapshot.data.docs;
        var returns = createwidget(ls);
        return Scaffold(
          appBar: AppBar(
            title: Text("Previous Data"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: returns,
          ),
        );
        // print(abc);
        // return Scaffold(
        //   body: Column(
        //     children: [
        //       abc.forEach((doc, index) => {Text(doc)})
        //     ],
        //   ),
      },
    );
  }
}
