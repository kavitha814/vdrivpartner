import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CampaignWorksScreen extends StatefulWidget {
  @override
  _CampaignWorksScreenState createState() => _CampaignWorksScreenState();
}

class _CampaignWorksScreenState extends State<CampaignWorksScreen> {
  int currentStep = 0;
  String? checkInSelfieImagePath;
  String? checkOutSelfieImagePath;
  Position? checkInLocation;
  Position? checkOutLocation;
  String? checkInPlaceName;
  String? checkOutPlaceName;
  Timer? dutyTimer;
  int dutySeconds = 0;

  final List<String> stepTitles = [
    'Trip Details',
    'Check-in',
    'Duty Timer',
    'Check-out',
    'Summary'
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

  Future<String> _getPlaceNameFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build a comprehensive address
        List<String> addressParts = [];
        
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        
        return addressParts.join(', ');
      }
      return 'Address not found';
    } catch (e) {
      print('Error getting place name: $e');
      return 'Unable to fetch address';
    }
  }

  Future<void> _getCurrentLocation(bool isCheckIn) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Getting location...'),
            ],
          ),
        ),
      );

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Navigator.pop(context);
        _showErrorDialog('Location services are disabled. Please enable location.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Navigator.pop(context);
          _showErrorDialog('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Navigator.pop(context);
        _showErrorDialog('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get place name from coordinates
      String placeName = await _getPlaceNameFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Navigator.pop(context);

      setState(() {
        if (isCheckIn) {
          checkInLocation = position;
          checkInPlaceName = placeName;
        } else {
          checkOutLocation = position;
          checkOutPlaceName = placeName;
        }
      });

      
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Error getting location: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
                  children: List.generate(5, (index) {
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
                Text(
                  _getCurrentStepLabel(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCurrentStepContent(),
            ),
          ),
          if (_shouldShowBottomButton()) _buildBottomButton(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  String _getCurrentStepLabel() {
    switch (currentStep) {
      case 0: return 'Step 1: View Trip Details';
      case 1: return 'Step 2: Check-in (Selfie + Location)';
      case 2: return 'Step 3: Complete Your Duty';
      case 3: return 'Step 4: Check-out (Selfie + Location)';
      case 4: return 'Step 5: View Summary & Payment';
      default: return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 0: return _buildTripDetailsStep();
      case 1: return _buildCheckInStep();
      case 2: return _buildDutyTimerStep();
      case 3: return _buildCheckOutStep();
      case 4: return _buildTripSummaryStep();
      default: return Container();
    }
  }

  Widget _buildTripDetailsStep() {
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
              Icon(Icons.login, color: Colors.green[600]),
              SizedBox(width: 8),
              Text('Check-in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text('Take a selfie and capture your location', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 24),
          
          // Selfie Section
          Center(
            child: GestureDetector(
              onTap: () => _takeSelfie(true),
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFFC107), width: 2),
                ),
                child: checkInSelfieImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(checkInSelfieImagePath!), fit: BoxFit.cover),
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
                          Text('Tap to take selfie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Location Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: checkInLocation != null ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: checkInLocation != null ? Colors.green : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      checkInLocation != null ? Icons.check_circle : Icons.location_on,
                      color: checkInLocation != null ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      checkInLocation != null ? 'Location Captured' : 'Capture Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (checkInLocation != null) ...[
                  SizedBox(height: 16),
                  // Place Name
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.place, color: Colors.green[600], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            checkInPlaceName ?? 'Loading address...',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latitude:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('${checkInLocation!.latitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Longitude:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('${checkInLocation!.longitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accuracy:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('±${checkInLocation!.accuracy.toStringAsFixed(1)}m', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutStep() {
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
              Icon(Icons.logout, color: Colors.red[600]),
              SizedBox(width: 8),
              Text('Check-out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text('Take a selfie and capture your location', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 24),
          
          // Selfie Section
          Center(
            child: GestureDetector(
              onTap: () => _takeSelfie(false),
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFFC107), width: 2),
                ),
                child: checkOutSelfieImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(checkOutSelfieImagePath!), fit: BoxFit.cover),
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
                          Text('Tap to take selfie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Location Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: checkOutLocation != null ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: checkOutLocation != null ? Colors.green : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      checkOutLocation != null ? Icons.check_circle : Icons.location_on,
                      color: checkOutLocation != null ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      checkOutLocation != null ? 'Location Captured' : 'Capture Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (checkOutLocation != null) ...[
                  SizedBox(height: 16),
                  // Place Name
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.place, color: Colors.green[600], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            checkOutPlaceName ?? 'Loading address...',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latitude:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('${checkOutLocation!.latitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Longitude:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('${checkOutLocation!.longitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accuracy:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('±${checkOutLocation!.accuracy.toStringAsFixed(1)}m', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ],
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
          Text(
            dutyTimer == null ? 'Start your duty timer' : 'Your duty is in progress',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFFFC107), width: 4),
                  ),
                  child: Text(
                    formatTime(dutySeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  dutyTimer != null ? 'Duty in progress' : 'Ready to start',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: dutyTimer != null
                        ? () {
                            dutyTimer?.cancel();
                            setState(() {
                              dutyTimer = null;
                            });
                            nextStep();
                          }
                        : () {
                            startDutyTimer();
                            setState(() {});
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dutyTimer != null ? Colors.red : Color(0xFFFFC107),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          dutyTimer != null ? Icons.stop : Icons.play_arrow,
                          color: dutyTimer != null ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          dutyTimer != null ? 'End Duty' : 'Start Duty',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dutyTimer != null ? Colors.white : Colors.black,
                          ),
                        ),
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

  Widget _buildTripSummaryStep() {
    double hourlyRate = 150.0;
    double totalHours = dutySeconds / 3600.0;
    double baseAmount = totalHours * hourlyRate;
    double bonus = 50.0;
    double totalEarnings = baseAmount + bonus;

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
          _buildSummarySection('Campaign Details', [
            _buildSummaryRow('Location', 'ICT Grand Chola'),
            _buildSummaryRow('Supervisor', 'Jayapradhaa'),
            _buildSummaryRow('Date', DateTime.now().toString().split(' ')[0]),
          ]),
          SizedBox(height: 20),
          _buildSummarySection('Time Details', [
            _buildSummaryRow('Duration', formatTime(dutySeconds)),
            _buildSummaryRow('Total Hours', '${totalHours.toStringAsFixed(2)} hrs'),
          ]),
          SizedBox(height: 20),
          _buildSummarySection('Location Verification', [
            _buildSummaryRow('Check-in', checkInLocation != null ? '✓ Verified' : '✗ Not captured'),
            if (checkInPlaceName != null)
              _buildSummaryRowFullWidth('Check-in Location', checkInPlaceName!),
            _buildSummaryRow('Check-out', checkOutLocation != null ? '✓ Verified' : '✗ Not captured'),
            if (checkOutPlaceName != null)
              _buildSummaryRowFullWidth('Check-out Location', checkOutPlaceName!),
          ]),
          SizedBox(height: 20),
          _buildSummarySection('Payment Details', [
            _buildSummaryRow('Hourly Rate', '₹${hourlyRate.toStringAsFixed(0)}/hr'),
            _buildSummaryRow('Base Amount', '₹${baseAmount.toStringAsFixed(2)}'),
            _buildSummaryRow('Bonus', '₹${bonus.toStringAsFixed(2)}'),
          ]),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFFFC107), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Earnings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '₹${totalEarnings.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Receipt downloaded!')),
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
                      Text('Receipt', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                      Text('Home', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
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
                    'Payment will be processed within 24 hours',
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
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
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

  Widget _buildSummaryRowFullWidth(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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

  bool _shouldShowBottomButton() {
    if (currentStep == 0) return true;
    if (currentStep == 1 && checkInSelfieImagePath != null && checkInLocation != null) return true;
    if (currentStep == 2) return false;
    if (currentStep == 3 && checkOutSelfieImagePath != null && checkOutLocation != null) return true;
    if (currentStep == 4) return false;
    return false;
  }

  Widget _buildBottomButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (currentStep) {
      case 0:
        buttonText = 'Start Journey';
        onPressed = nextStep;
        break;
      case 1:
        buttonText = 'Continue to Duty Timer';
        onPressed = nextStep;
        break;
      case 3:
        buttonText = 'View Summary';
        onPressed = nextStep;
        break;
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

  void _takeSelfie(bool isCheckIn) async {
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
          if (isCheckIn) {
            checkInSelfieImagePath = image.path;
          } else {
            checkOutSelfieImagePath = image.path;
          }
        });

        // Auto-capture location after selfie
        await Future.delayed(Duration(milliseconds: 500));
        _getCurrentLocation(isCheckIn);
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