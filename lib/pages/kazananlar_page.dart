import 'package:flutter/material.dart';

class KazananlarPage extends StatelessWidget {
  List<String> kazananlar;
  KazananlarPage({super.key, required this.kazananlar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context);          }, 
            icon: Icon(Icons.arrow_back, color: Colors.white,)),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(child: ListView.builder(
              itemCount: kazananlar.length,
              itemBuilder: (context, i){
              return ListTile(leading: Text("${i+1}", style: TextStyle(color: Colors.white),), title: Text(kazananlar[i], style: TextStyle(color: Colors.white),),);
            })),
          ],
        ),
      ),
    );
  }
}