import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jackpot/main.dart';
import 'package:jackpot/pages/kazananlar_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawScreen extends StatefulWidget {
  final String userName;
  DrawScreen({super.key, required this.userName});

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<String> participants = [];
  String? winner;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  List<String> kazananlar = [];

  // Save game record to Firestore with readable timestamp
  Future<void> saveGameRecord(List<String> winners, int winnerCount) async {
    final record = {
      'players': participants,
      'winners': winners,
      'winnerCount': winnerCount,
      'timestamp': FieldValue.serverTimestamp(), // Use Firestore timestamp
      'createdBy': widget.userName,
      'gameType': 'normal', // <--- Add this line
    };
    await FirebaseFirestore.instance.collection('games').add(record);
  }

  // Fetch previous games and show in dialog
  Future<void> showPreviousGamesDialog() async {
    final query =
        await FirebaseFirestore.instance
            .collection('games')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();
    final records = query.docs.map((doc) => doc.data()).toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Son 10 Çekiliş"),
            content: SizedBox(
              width: 400,
              child:
                  records.isEmpty
                      ? Text("Kayıt yok.")
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: records.length,
                        itemBuilder: (context, i) {
                          final data = records[i];
                          final players = (data['players'] as List).join(', ');
                          final winners = (data['winners'] as List).join(', ');
                          final winnerCount = data['winnerCount'] ?? 0;
                          final createdBy = data['createdBy'] ?? '';
                          final timestamp = data['timestamp'] ?? '';
                          return ListTile(
                            title: Text("Kazananlar: $winners"),
                            subtitle: Text(
                              "Oyuncular: $players\nKazanan Sayısı: $winnerCount\nOluşturan: $createdBy\nTarih: $timestamp",
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Kapat"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Çekiliş Ekranı"),
        actions: [
          ElevatedButton(
            onPressed: showPreviousGamesDialog,
            child: Text("Geçmiş Çekilişler"),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(controller: _controller),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isEmpty) return;
                    setState(() {
                      participants.add(_controller.text);
                      _controller.clear();
                    });
                  },
                  child: Text("Ekle"),
                ),
                SizedBox(height: 10, width: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            content: TextField(
                              controller: _numberController,
                              decoration: InputDecoration(
                                label: Text("Kazanan sayısı girin"),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Random ran = Random();
                                  kazananlar = [];
                                  for (
                                    var i = 0;
                                    i < int.parse(_numberController.text);
                                    i++
                                  ) {
                                    int sayi = ran.nextInt(participants.length);
                                    kazananlar.add(participants[sayi]);
                                  }
                                  // Save multi-winner game to Firestore
                                  saveGameRecord(kazananlar, kazananlar.length);
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => KazananlarPage(
                                            kazananlar: kazananlar,
                                          ),
                                    ),
                                  ).then((_) {
                                    kazananlar = [];
                                  });
                                },
                                child: Text("Çekiliş Yap"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Text("Çekiliş yap"),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder:
                    (context, i) => ListTile(
                      leading: Icon(Icons.person),
                      title: Text(participants[i]),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
