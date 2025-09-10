import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/duty_timer_page.dart';
import 'package:vdrivpartner/widgets/bottom_nav_bar.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _isCheckingIn = false;

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
            _buildProgressBar('Check-in'),
            SizedBox(height: 24),
            _buildCheckInCard(),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCheckingIn
                      ? null
                      : () {
                          setState(() {
                            _isCheckingIn = true;
                          });
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DutyTimerPage()),
                            );
                            setState(() {
                              _isCheckingIn = false;
                            });
                          });
                        },
                  child: Text(
                    _isCheckingIn ? 'Checking in...' : 'Take selfie to Check-in',
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

  Widget _buildProgressBar(String stage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('Check-in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('Duty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Container(height: 2, color: Colors.black)),
              SizedBox(width: 5),
              Icon(Icons.directions_car, color: Colors.black, size: 24),
              SizedBox(width: 5),
              Expanded(child: Container(height: 2, color: Colors.grey[300])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
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
            Row(children: [Icon(Icons.location_on, color: Colors.black), SizedBox(width: 8), Text('Check-in Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            SizedBox(height: 8),
            Text('Please take a selfie to confirm your arrival at the venue.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 16),
            Center(
              child: CustomPaint(
                painter: DashedBorderPainter(color: Color(0xFFffd300), strokeWidth: 1.5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 40, color: Color(0xFFF1C40F)),
                      SizedBox(height: 8),
                      Text('Tap to take selfie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Position your face in center', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw the dashed border.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final path = Path();
    double current = 0;
    
    // Draw top
    while (current < rect.width) {
      path.moveTo(rect.left + current, rect.top);
      path.lineTo(rect.left + current + dashWidth, rect.top);
      current += dashWidth + dashSpace;
    }

    // Draw right
    current = 0;
    while (current < rect.height) {
      path.moveTo(rect.right, rect.top + current);
      path.lineTo(rect.right, rect.top + current + dashWidth);
      current += dashWidth + dashSpace;
    }

    // Draw bottom
    current = 0;
    while (current < rect.width) {
      path.moveTo(rect.right - current, rect.bottom);
      path.lineTo(rect.right - current - dashWidth, rect.bottom);
      current += dashWidth + dashSpace;
    }

    // Draw left
    current = 0;
    while (current < rect.height) {
      path.moveTo(rect.left, rect.bottom - current);
      path.lineTo(rect.left, rect.bottom - current - dashWidth);
      current += dashWidth + dashSpace;
    }
    
    // This simplified method doesn't draw dashed corners, but it provides a clean, functional solution.

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}