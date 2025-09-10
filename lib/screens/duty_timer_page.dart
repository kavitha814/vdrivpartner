import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vdrivpartner/widgets/bottom_nav_bar.dart';

class DutyTimerPage extends StatefulWidget {
  @override
  _DutyTimerPageState createState() => _DutyTimerPageState();
}

class _DutyTimerPageState extends State<DutyTimerPage> {
  Timer? _timer;
  int _seconds = 0;
  bool _isDutyStarted = false;

  void _startTimer() {
    setState(() {
      _isDutyStarted = true;
    });
    const oneSecond = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSecond,
      (Timer timer) {
        setState(() {
          _seconds++;
        });
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isDutyStarted = false;
      _seconds = 0; // Reset timer
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('VDriv'),
        actions: [
          Row(
            children: [
              Icon(Icons.language, color: Colors.black),
              SizedBox(width: 4),
              Text('English', style: TextStyle(color: Colors.black)),
              SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Campaign Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            _buildProgressBar('Duty', _isDutyStarted, _seconds),
            SizedBox(height: 24),
            _buildDutyTimerCard(),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isDutyStarted ? null : _startTimer,
                  child: Text(
                    _isDutyStarted ? 'Running...' : 'Start Duty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD300),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _buildProgressBar(String stage, bool isRunning, int seconds) {
    double progress = isRunning ? (seconds % 60) / 60 : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Check-in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Duty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              double carPosition = constraints.maxWidth * progress;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    children: [
                      Expanded(child: Container(height: 2, color: Colors.black)),
                      SizedBox(width: 30),
                      Expanded(child: Container(height: 2, color: Colors.black)),
                    ],
                  ),
                  Positioned(
                    left: carPosition,
                    child: Icon(Icons.directions_car, color: Colors.black, size: 24),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDutyTimerCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Color(0xFFffd300), width: 1.5)),
      color: Color(0xffFFFDF1).withOpacity(0.57),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.access_time, color: Colors.black), SizedBox(width: 8), Text('Duty Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            SizedBox(height: 8),
            Text('Please start the timer when your duty starts', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isDutyStarted ? 'Running...' : 'Ready to start',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}