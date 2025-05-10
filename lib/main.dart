// Tüm gerekli importlar

import 'package:flutter/material.dart';
import 'package:jackpot/pages/draw_screen.dart';
import 'package:jackpot/pages/kayitli_oyunlar_page.dart';
import 'dart:math';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Çekiliş Uygulaması',
      theme: ThemeData.dark(),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // User is signed in
          final user = snapshot.data!;
          return HomeScreen(userName: user.email ?? "Kullanıcı");
        }
        // Not signed in
        return AnimatedLoginPage();
      },
    );
  }
}

// Giriş Ekranı
class LoginScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Adınızı girin"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(userName: nameController.text),
                  ),
                );
              },
              child: Text("Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}

// Ana Menü Ekranı
class HomeScreen extends StatelessWidget {
  final String userName;
  static List<String> previousWinners = [];

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hoşgeldin, $userName"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Çıkış Yap",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Çekiliş Yap"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrawScreen(userName: userName),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text("Oyunlar"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameToolsScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text("Geçmiş Çekilişler"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameHistoryPage()),
                );
              },
            ),
            if (previousWinners.contains(userName))
              ElevatedButton(
                child: Text("Jackpot Boss"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JackpotBossScreen(userName: userName),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Çekiliş Ekranı

// Oyunlar Ekranı
class GameToolsScreen extends StatelessWidget {
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final Random random = Random();

  GameToolsScreen({super.key});

  int rollDice(int sides) => random.nextInt(sides) + 1;
  String flipCoin() => random.nextBool() ? "Yazı" : "Tura";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Oyunlar")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Zar At"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("6'lık Zar"),
                  onPressed: () {
                    final result = rollDice(6);
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(content: Text("Sonuç: $result")),
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("20'lik Zar"),
                  onPressed: () {
                    final result = rollDice(20);
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(content: Text("Sonuç: $result")),
                    );
                  },
                ),
              ],
            ),
            Divider(),
            Text("Yazı Tura"),
            ElevatedButton(
              child: Text("At"),
              onPressed: () {
                final result = flipCoin();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(content: Text("Sonuç: $result")),
                );
              },
            ),
            Divider(),
            Text("Rastgele Sayı Seç"),
            TextField(
              controller: minController,
              decoration: InputDecoration(labelText: "Min"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: maxController,
              decoration: InputDecoration(labelText: "Max"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              child: Text("Seç"),
              onPressed: () {
                int min = int.tryParse(minController.text) ?? 0;
                int max = int.tryParse(maxController.text) ?? 100;
                final result = min + random.nextInt(max - min + 1);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(content: Text("Sonuç: $result")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Jackpot Boss DDR Ekranı
class JackpotBossScreen extends StatefulWidget {
  final String userName;
  const JackpotBossScreen({super.key, required this.userName});

  @override
  _JackpotBossScreenState createState() => _JackpotBossScreenState();
}

class _JackpotBossScreenState extends State<JackpotBossScreen> {
  int successRate = 0;
  bool isDancing = false;
  Timer? timer;

  void startDDR() {
    int beats = 0;
    const int totalBeats = 15;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        beats++;
        bool hit = Random().nextBool();
        if (hit) {
          successRate += 7;
          isDancing = true;
        } else {
          successRate -= 5;
          isDancing = false;
        }
        if (beats == totalBeats) {
          timer.cancel();
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: Text("Jackpot Sonuçları"),
                  content:
                      successRate >= 70 && Random().nextDouble() < 0.2
                          ? Text("ÇIN ÇIN ÇIN! JACKPOT! 🎉")
                          : Text("Jackpot Kaçtı 😢"),
                ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Jackpot Boss")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDancing ? Icons.music_note : Icons.music_off,
              size: 100,
              color: isDancing ? Colors.greenAccent : Colors.red,
            ),
            Text("Başarı Oranı: $successRate%"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startDDR,
              child: Text("DDR Başlat (15sn)"),
            ),
          ],
        ),
      ),
    );
  }
}

// Geçmiş Çekilişler Ekranı
class GameHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geçmiş Çekilişler")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('games')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text("Kayıt yok.", style: TextStyle(color: Colors.white)),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final players = (data['players'] as List).join(', ');
              final winners = (data['winners'] as List).join(', ');
              final winnerCount = data['winnerCount'] ?? 0;
              final createdBy = data['createdBy'] ?? '';
              final timestampRaw = data['timestamp'];
              String timestamp = '';
              if (timestampRaw != null) {
                if (timestampRaw is Timestamp) {
                  timestamp = timestampRaw.toDate().toString();
                } else if (timestampRaw is String) {
                  timestamp = timestampRaw;
                }
              }
              return ListTile(
                title: Text(
                  "Kazananlar: $winners",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Oyuncular: $players\nKazanan Sayısı: $winnerCount\nOluşturan: $createdBy\nTarih: $timestamp",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
