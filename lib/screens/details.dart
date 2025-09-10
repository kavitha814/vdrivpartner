import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Main Campaign Works Screen with stepper flow
class CampaignWorksScreen extends StatefulWidget {
  @override
  _CampaignWorksScreenState createState() => _CampaignWorksScreenState();
}

class _CampaignWorksScreenState extends State<CampaignWorksScreen> {
  int currentStep = 0;
  bool isJourneyStarted = false;
  String? selfieImagePath;
  Timer? dutyTimer;
  int dutySeconds = 0;

  final List<String> stepTitles = [
    'Select Slot',
    'Check-in',
    'Duty Timer',
    'Trip Summary'
  ];

  @override
  void dispose() {
    dutyTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < stepTitles.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void startJourney() {
    setState(() {
      isJourneyStarted = true;
    });
    nextStep();
  }

  void startDutyTimer() {
    dutyTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        dutySeconds++;
      });
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFFFC107),
        elevation: 0,
        title: Text('VDriv', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.language, color: Colors.black),
                SizedBox(width: 4),
                Text('English', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campaign Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  children: List.generate(stepTitles.length, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= currentStep ? Color(0xFFFFC107) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (currentStep >= 1) Text('Check-in', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (currentStep >= 2) Text('Duty', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (currentStep >= 3) Text('Summary', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCurrentStepContent(),
            ),
          ),
          if (currentStep < stepTitles.length) _buildBottomButton(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 0:
        return _buildSlotSelectionStep();
      case 1:
        return _buildCheckInStep();
      case 2:
        return _buildDutyTimerStep();
      case 3:
        return _buildTripSummaryStep();
      default:
        return Container();
    }
  }

  Widget _buildSlotSelectionStep() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text('Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text('Campaign Work', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          SizedBox(height: 24),
          _buildDetailCard(Icons.location_on, 'Location', 'ICT Grand Chola'),
          SizedBox(height: 16),
          _buildDetailCard(Icons.access_time, 'Time', '08:00 AM - 01:00 PM'),
          SizedBox(height: 16),
          _buildDetailCard(Icons.person, 'Supervisor', 'Jayapradhaa'),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.navigation, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text('Navigation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Text('Distance : 12 km', style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue[100],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.blue),
                        SizedBox(height: 8),
                        Text('Map View', style: TextStyle(color: Colors.blue[700])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInStep() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text('Check-in Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          Text('Please take a selfie to confirm your arrival at the venue.',
               style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: _takeSelfie,
              child: Container(
                width: 250,
                height: 300,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFFC107), style: BorderStyle.solid, width: 2),
                ),
                child: selfieImagePath != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(selfieImagePath!), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFC107),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, size: 32, color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text('Tap to take selfie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Position your face in center', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyTimerStep() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text('Duty Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          Text('Click the timer button below to start your duty',
               style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  formatTime(dutySeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  dutyTimer != null ? 'Duty in progress' : 'Ready to start duty',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: dutyTimer != null ? () {
                    dutyTimer?.cancel();
                    setState(() {
                      dutyTimer = null;
                    });
                    nextStep(); // Move to trip summary instead of showing dialog
                  } : () {
                    startDutyTimer();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dutyTimer != null ? Colors.red : Color(0xFFFFC107),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        dutyTimer != null ? Icons.stop : Icons.play_arrow, 
                        color: dutyTimer != null ? Colors.white : Colors.black
                      ),
                      SizedBox(width: 8),
                      Text(
                        dutyTimer != null ? 'End Duty' : 'Start Duty', 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: dutyTimer != null ? Colors.white : Colors.black
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryStep() {
    // Calculate earnings based on hourly rate
    double hourlyRate = 150.0; // ₹150 per hour
    double totalHours = dutySeconds / 3600.0;
    double totalEarnings = totalHours * hourlyRate;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green[600]),
              SizedBox(width: 8),
              Text('Trip Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, size: 48, color: Colors.green[600]),
                SizedBox(height: 8),
                Text(
                  'Trip Completed Successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Campaign Details
          _buildSummarySection('Campaign Details', [
            _buildSummaryRow('Campaign Name', 'Brand Promotion Campaign'),
            _buildSummaryRow('Location', 'ICT Grand Chola'),
            _buildSummaryRow('Supervisor', 'Jayapradhaa'),
            _buildSummaryRow('Date', DateTime.now().toString().split(' ')[0]),
          ]),
          
          SizedBox(height: 20),
          
          // Time Details
          _buildSummarySection('Time Details', [
            _buildSummaryRow('Start Time', '08:00 AM'),
            _buildSummaryRow('End Time', DateTime.now().toString().split(' ')[1].substring(0, 5)),
            _buildSummaryRow('Total Duration', formatTime(dutySeconds)),
            _buildSummaryRow('Break Time', '00:00:00'),
          ]),
          
          SizedBox(height: 20),
          
          // Payment Details
          _buildSummarySection('Payment Details', [
            _buildSummaryRow('Hourly Rate', '₹${hourlyRate.toStringAsFixed(0)}/hr'),
            _buildSummaryRow('Total Hours', '${totalHours.toStringAsFixed(2)} hrs'),
            _buildSummaryRow('Base Amount', '₹${totalEarnings.toStringAsFixed(2)}'),
            _buildSummaryRow('Bonus', '₹50.00'),
          ]),
          
          SizedBox(height: 16),
          
          // Total Earnings
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFFFC107)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Earnings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${(totalEarnings + 50).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Download or view receipt
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Receipt downloaded successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Download Receipt', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to main screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC107),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Go Home', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Payment Status
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment will be processed within 24 hours and credited to your account.',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (currentStep) {
      case 0:
        buttonText = 'Start Journey';
        onPressed = startJourney;
        break;
      case 1:
        buttonText = selfieImagePath != null ? 'Continue to Duty Timer' : 'Take Selfie to Check-in';
        onPressed = selfieImagePath != null ? nextStep : _takeSelfie;
        break;
      case 2:
        return Container(); // No bottom button for duty timer step as it has its own button
      case 3:
        return Container(); // No bottom button for trip summary step
      default:
        return Container();
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFC107),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFFFFC107),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _takeSelfie() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selfieImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking selfie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Duty Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Total duty time: ${formatTime(dutySeconds)}'),
            SizedBox(height: 8),
            Text('Your payment will be processed shortly.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class WorkTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Work Type'),
        backgroundColor: Color(0xFFFFC107),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWorkTypeCard(
              'Campaign Works',
              'Bulk drivers for events',
              Icons.campaign,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignWorksScreen())),
            ),
            SizedBox(height: 16),
            _buildWorkTypeCard(
              'RTO Works',
              'Car registration trips',
              Icons.assignment,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => RTOWorksScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkTypeCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: Color(0xFFFFC107)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class RTOWorksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RTO Works'),
        backgroundColor: Color(0xFFFFC107),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('RTO Works Flow'),
            Text('Upload vehicle photo → Fill slip → Timer → Check-out selfie → Upload slip → Submit'),
          ],
        ),
      ),
    );
  }
}