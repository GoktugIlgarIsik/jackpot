import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cark extends StatefulWidget {
  final List<String> isimler;
  const Cark({super.key, required this.isimler});

  @override
  State<Cark> createState() => _CarkState();
}

class _CarkState extends State<Cark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _kazananIndex = 0;
  double _currentRotation = 0;
  double _finalRotation = 0;
  final Random _random = Random();
  bool _gameSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation =
        Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
          ..addListener(() {
            setState(() {
              _currentRotation = _animation.value * _finalRotation;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              double sliceAngle = 2 * pi / widget.isimler.length;
              double normalizedRotation = _currentRotation % (2 * pi);
              double pointerAngle =
                  (3 * pi / 2 - normalizedRotation) % (2 * pi);
              if (pointerAngle < 0) pointerAngle += 2 * pi;
              int index = pointerAngle ~/ sliceAngle;
              setState(() {
                _kazananIndex = index;
                _gameSaved = false;
              });
            }
          });
  }

  Future<void> _saveCarkGame() async {
    if (_gameSaved) return;
    final kazanan = widget.isimler[_kazananIndex];
    final record = {
      'players': widget.isimler,
      'winners': [kazanan],
      'winnerCount': 1,
      'timestamp': FieldValue.serverTimestamp(),
      'gameType': 'cark',
    };
    await FirebaseFirestore.instance.collection('games').add(record);
    setState(() {
      _gameSaved = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Çarklı çekiliş kaydedildi!")));
  }

  void _cevirCarki() {
    int randomTur = 5 + _random.nextInt(5); // 5–9 tur
    double randomEkAci = _random.nextDouble() * 2 * pi; // 0–2π arası

    _finalRotation = 2 * pi * randomTur + randomEkAci;

    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çarklı Çekiliş')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: AlwaysStoppedAnimation(_currentRotation / (2 * pi)),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: CustomPaint(painter: CarkPainter(widget.isimler)),
                  ),
                ),
                const Positioned(
                  top: 0,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _cevirCarki, child: const Text('Çevir')),
            const SizedBox(height: 20),
            if (_controller.isCompleted)
              Column(
                children: [
                  Text(
                    'Kazanan: ${widget.isimler[_kazananIndex]}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveCarkGame,
                    child: Text(_gameSaved ? "Kaydedildi" : "Sonucu Kaydet"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class CarkPainter extends CustomPainter {
  final List<String> isimler;
  CarkPainter(this.isimler);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    double sliceAngle = 2 * pi / isimler.length;
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < isimler.length; i++) {
      paint.color = Colors.primaries[i % Colors.primaries.length];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        i * sliceAngle,
        sliceAngle,
        true,
        paint,
      );

      // İsimleri yerleştir
      final angle = (i + 0.5) * sliceAngle;
      final offset = Offset(
        radius + radius * 0.6 * cos(angle),
        radius + radius * 0.6 * sin(angle),
      );

      textPainter.text = TextSpan(
        text: isimler[i],
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
