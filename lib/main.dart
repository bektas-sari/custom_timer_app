import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CustomTimerApp());
}

class CustomTimerApp extends StatelessWidget {
  const CustomTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Timer',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const TimerHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  Timer? _timer;
  bool isRunning = false;

  int selectedSeconds = 60;
  int currentSeconds = 60;

  void _startTimer() {
    if (_timer != null) return;
    setState(() {
      currentSeconds = selectedSeconds;
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds > 0) {
        setState(() {
          currentSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      currentSeconds = selectedSeconds;
    });
  }

  double get _progress =>
      selectedSeconds == 0 ? 0 : currentSeconds / selectedSeconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isRunning) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Select Time (seconds)",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Slider(
                min: 10,
                max: 300,
                divisions: 29,
                value: selectedSeconds.toDouble(),
                label: '$selectedSeconds s',
                onChanged: (value) {
                  setState(() {
                    selectedSeconds = value.round();
                    currentSeconds = selectedSeconds;
                  });
                },
              ),
            ],
            const SizedBox(height: 20),
            CustomPaint(
              painter: TimerPainter(progress: _progress),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Text(
                    '$currentSeconds s',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isRunning ? _stopTimer : _startTimer,
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.replay),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;

  TimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPaint =
        Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final foregroundPaint =
        Paint()
          ..color = Colors.deepPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
