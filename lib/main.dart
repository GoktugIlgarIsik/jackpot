// Tüm gerekli importlar

import 'package:flutter/material.dart';
import 'package:jackpot/pages/draw_screen.dart';
import 'package:jackpot/pages/kayitli_oyunlar_page.dart';
import 'dart:math';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/cark.dart';
import 'pages/kazananlar_page.dart';

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

  void _showCarkNameDialog(BuildContext context) {
    final controller = TextEditingController(text: "Ali,Veli,Ayşe,Fatma");
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Çarklı Çekiliş İsimleri"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "İsimleri virgül ile ayırarak girin",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("İptal"),
              ),
              ElevatedButton(
                onPressed: () {
                  final names =
                      controller.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                  if (names.length < 2) return;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Cark(isimler: names)),
                  );
                },
                child: Text("Başlat"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25252B),
      appBar: AppBar(
        title: Text("Hoşgeldin, $userName"),
        backgroundColor: Color(0xFF2D2D39),
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
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Color(0xFF2D2D39),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.emoji_events,
                    color: Colors.orangeAccent,
                    size: 32,
                  ),
                  title: Text(
                    "Çekiliş Yap",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DrawScreen(userName: userName),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Color(0xFF2D2D39),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.casino,
                    color: Colors.orangeAccent,
                    size: 32,
                  ),
                  title: Text(
                    "Zar Atma",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GameToolsScreen()),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Color(0xFF2D2D39),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.history,
                    color: Colors.orangeAccent,
                    size: 32,
                  ),
                  title: Text(
                    "Geçmiş Çekilişler",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GameHistoryPage()),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              if (previousWinners.contains(userName))
                Card(
                  color: Color(0xFF2D2D39),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.star,
                      color: Colors.orangeAccent,
                      size: 32,
                    ),
                    title: Text(
                      "Jackpot Boss",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JackpotBossScreen(userName: userName),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16),
              Card(
                color: Color(0xFF2D2D39),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.wheelchair_pickup,
                    color: Colors.orangeAccent,
                    size: 32,
                  ),
                  title: Text(
                    "Çarklı Çekiliş",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _showCarkNameDialog(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Çekiliş Ekranı
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

  Future<void> saveGameRecord(List<String> winners, int winnerCount) async {
    final record = {
      'players': participants,
      'winners': winners,
      'winnerCount': winnerCount,
      'timestamp': FieldValue.serverTimestamp(),
      'createdBy': widget.userName,
      'gameType': 'normal',
    };
    await FirebaseFirestore.instance.collection('games').add(record);
  }

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
            backgroundColor: Color(0xFF2D2D39),
            title: Text(
              "Son 10 Çekiliş",
              style: TextStyle(color: Colors.orangeAccent),
            ),
            content: SizedBox(
              width: 400,
              child:
                  records.isEmpty
                      ? Text(
                        "Kayıt yok.",
                        style: TextStyle(color: Colors.white),
                      )
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
                          return Card(
                            color: Colors.black54,
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(
                                "Kazananlar: $winners",
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                              subtitle: Text(
                                "Oyuncular: $players\nKazanan Sayısı: $winnerCount\nOluşturan: $createdBy\nTarih: $timestamp",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Kapat",
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25252B),
      appBar: AppBar(
        title: Text("Çekiliş Ekranı"),
        backgroundColor: Color(0xFF2D2D39),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: showPreviousGamesDialog,
            child: Text("Geçmiş Çekilişler"),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(24),
          child: Card(
            color: Color(0xFF2D2D39),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Katılımcı Ekle",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "İsim girin",
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (_controller.text.isEmpty) return;
                          setState(() {
                            participants.add(_controller.text);
                            _controller.clear();
                          });
                        },
                        child: Text("Ekle"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Colors.black54,
                    child: SizedBox(
                      height: 120,
                      child:
                          participants.isEmpty
                              ? Center(
                                child: Text(
                                  "Henüz katılımcı yok.",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                              : ListView.builder(
                                itemCount: participants.length,
                                itemBuilder:
                                    (context, i) => ListTile(
                                      leading: Icon(
                                        Icons.person,
                                        color: Colors.orangeAccent,
                                      ),
                                      title: Text(
                                        participants[i],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                              ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _numberController,
                          decoration: InputDecoration(
                            labelText: "Kazanan sayısı",
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.emoji_events),
                        label: Text("Çekiliş Yap"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (_numberController.text.isEmpty ||
                              participants.isEmpty)
                            return;
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
                          saveGameRecord(kazananlar, kazananlar.length);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      KazananlarPage(kazananlar: kazananlar),
                            ),
                          ).then((_) {
                            kazananlar = [];
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Oyunlar Ekranı
class GameToolsScreen extends StatefulWidget {
  GameToolsScreen({super.key});

  @override
  State<GameToolsScreen> createState() => _GameToolsScreenState();
}

class _GameToolsScreenState extends State<GameToolsScreen> {
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final Random random = Random();

  int diceCount = 1;
  List<int> diceValues = [1];
  String? coinResult; // "yazi" or "tura"

  void rollAllDice() {
    setState(() {
      diceValues = List.generate(diceCount, (_) => random.nextInt(6) + 1);
    });
  }

  String getDice6Asset(int value) => 'assets/images/dice$value.png';

  String flipCoin() => random.nextBool() ? "yazi" : "tura";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Oyunlar")),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  color: Color(0xFF2D2D39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "6'lık Zar At (1-5 adet)",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Zar Sayısı: ",
                              style: TextStyle(color: Colors.white),
                            ),
                            DropdownButton<int>(
                              value: diceCount,
                              dropdownColor: Color(0xFF2D2D39),
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              items:
                                  List.generate(5, (i) => i + 1)
                                      .map(
                                        (count) => DropdownMenuItem(
                                          value: count,
                                          child: Text("$count"),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    diceCount = val;
                                    diceValues = List.generate(
                                      diceCount,
                                      (_) => 1,
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            diceCount,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orangeAccent.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  getDice6Asset(diceValues[i]),
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: rollAllDice,
                          icon: Icon(Icons.casino),
                          label: Text("${diceCount} Zar At"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  color: Color(0xFF2D2D39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Yazı Tura",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (coinResult != null)
                          Column(
                            children: [
                              Image.asset(
                                'assets/images/${coinResult!}.png',
                                width: 80,
                                height: 80,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Sonuç: ${coinResult == "yazi" ? "Yazı" : "Tura"}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: Icon(Icons.flip),
                          label: Text("At"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            final result = flipCoin();
                            setState(() {
                              coinResult = result;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  color: Color(0xFF2D2D39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Rastgele Sayı Seç",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: minController,
                                decoration: InputDecoration(
                                  labelText: "Min",
                                  filled: true,
                                  fillColor: Colors.black26,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: maxController,
                                decoration: InputDecoration(
                                  labelText: "Max",
                                  filled: true,
                                  fillColor: Colors.black26,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.shuffle),
                          label: Text("Seç"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            int min = int.tryParse(minController.text) ?? 0;
                            int max = int.tryParse(maxController.text) ?? 100;
                            final result = min + random.nextInt(max - min + 1);
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    backgroundColor: Color(0xFF2D2D39),
                                    title: Text(
                                      "Sonuç",
                                      style: TextStyle(
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                    content: Text(
                                      "Sonuç: $result",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      backgroundColor: Color(0xFF25252B),
      appBar: AppBar(
        title: Text("Geçmiş Çekilişler"),
        backgroundColor: Color(0xFF2D2D39),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
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
                  child: Text(
                    "Kayıt yok.",
                    style: TextStyle(color: Colors.white),
                  ),
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
                  final gameType = data['gameType'] ?? 'normal';
                  final timestampRaw = data['timestamp'];
                  String timestamp = '';
                  if (timestampRaw != null) {
                    if (timestampRaw is Timestamp) {
                      timestamp = timestampRaw.toDate().toString();
                    } else if (timestampRaw is String) {
                      timestamp = timestampRaw;
                    }
                  }
                  return Card(
                    color: Color(0xFF2D2D39),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        gameType == "cark"
                            ? Icons.wheelchair_pickup
                            : Icons.emoji_events,
                        color: Colors.orangeAccent,
                        size: 32,
                      ),
                      title: Text(
                        "Kazananlar: $winners",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Oyun Türü: $gameType\nOyuncular: $players\nKazanan Sayısı: $winnerCount\nOluşturan: $createdBy\nTarih: $timestamp",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
