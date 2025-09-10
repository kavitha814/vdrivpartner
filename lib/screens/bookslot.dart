import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/check_in_page.dart';
import 'package:vdrivpartner/widgets/bottom_nav_bar.dart';

class BookingDetailsPage extends StatefulWidget {
  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool _isJourneyStarted = false;

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
            _buildProgressWidget(),
            SizedBox(height: 24),
            _buildTripDetailsCard(),
            SizedBox(height: 16),
            _buildNavigationCard(),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isJourneyStarted
                      ? null
                      : () {
                          setState(() {
                            _isJourneyStarted = true;
                          });
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CheckInPage()),
                            );
                            setState(() {
                              _isJourneyStarted = false;
                            });
                          });
                        },
                  child: Text(
                    'Start Journey',
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

  Widget _buildProgressWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isJourneyStarted
              ? Text('Loading...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black))
              : Text('Select', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _isJourneyStarted
                    ? SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(backgroundColor: Colors.grey[300], color: Colors.black),
                      )
                    : Container(height: 2, color: Colors.black),
              ),
              SizedBox(width: 10),
              Icon(Icons.directions_car, color: Colors.black, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard() {
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
            Row(children: [Icon(Icons.location_on, color: Colors.black), SizedBox(width: 8), Text('Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            SizedBox(height: 8),
            Text('Campaign Work', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 16),
            _buildInfoRow(icon: Icons.location_on, title: 'Location', subtitle: 'ICT Grand Chola'),
            SizedBox(height: 12),
            _buildInfoRow(icon: Icons.access_time, title: 'Time', subtitle: '08:00 AM - 01:00 PM'),
            SizedBox(height: 12),
            _buildInfoRow(icon: Icons.person_outline, title: 'Supervisor', subtitle: 'Jayapradhaa'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xFFE0E0E0))),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard() {
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
            Row(children: [Icon(Icons.location_on_outlined, color: Colors.black), SizedBox(width: 8), Text('Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Spacer(), Text('Distance : 12 km', style: TextStyle(fontSize: 14, color: Colors.grey[600]))]),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://i.imgur.com/w2YvO0L.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}