import 'package:flutter/material.dart';
import 'package:jackpot/model/on_ayar.dart';
import 'package:jackpot/pages/draw_screen.dart';

class KayitliOyunlarPage extends StatefulWidget {
  const KayitliOyunlarPage({super.key});

  @override
  State<KayitliOyunlarPage> createState() => _KayitliOyunlarPageState();
}

class _KayitliOyunlarPageState extends State<KayitliOyunlarPage> {
  List<OnAyar> liste = [
    OnAyar(ad: "yılbaşı", id: 1, kisiler: ["alper", "ılgar"]),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          title: Text(
            "Kayıtlı ön ayar seçin",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: liste.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrawScreen(userName: "alper"),
                        ),
                      );
                    },
                    leading: Icon(Icons.save, color: Colors.white),
                    title: Text(
                      liste[i].ad,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
