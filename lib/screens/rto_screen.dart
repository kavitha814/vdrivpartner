import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RTOWorksScreen extends StatefulWidget {
  @override
  _RTOWorksScreenState createState() => _RTOWorksScreenState();
}

class _RTOWorksScreenState extends State<RTOWorksScreen> {
  int currentStep = 0;
  
  // Check-in data
  String? checkInSelfieImagePath;
  Position? checkInLocation;
  String? checkInPlaceName;
  
  // Vehicle photos (minimum 4)
  List<String> vehiclePhotos = [];
  
  // Duty sheet photo
  String? dutySheetImagePath;
  
  // Timer
  Timer? dutyTimer;
  int dutySeconds = 0;
  
  // Check-out data
  String? checkOutSelfieImagePath;
  Position? checkOutLocation;
  String? checkOutPlaceName;
  
  // Slip details form
  final _formKey = GlobalKey<FormState>();
  String? selectedWorkType;
  String? selectedPickupLocation;
  String? selectedDropLocation;
  TextEditingController rtoNameController = TextEditingController();
  TextEditingController chassisNumberController = TextEditingController();
  String? slipImagePath;
  
  // Prefilled data (would come from backend)
  final String clientName = "Hyundai Motors";
  final String branchName = "Guindy Showroom";
  DateTime? inTime;
  DateTime? outTime;
  
  final List<String> workTypes = ['RTO', 'DEL', 'SER (Valet)'];
  final List<String> pickupLocations = [
    'Hyundai Showroom, Guindy',
    'Customer Location - Anna Nagar',
    'Customer Location - T Nagar',
    'Warehouse - Ambattur'
  ];
  final List<String> dropLocations = [
    'RTO Office - Guindy',
    'RTO Office - Ashok Nagar',
    'Customer Location',
    'Showroom'
  ];

  @override
  void dispose() {
    dutyTimer?.cancel();
    rtoNameController.dispose();
    chassisNumberController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < 5) {
      setState(() {
        currentStep++;
      });
    }
  }

  void startDutyTimer() {
    inTime = DateTime.now();
    dutyTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        dutySeconds++;
      });
    });
  }

  void stopDutyTimer() {
    outTime = DateTime.now();
    dutyTimer?.cancel();
    setState(() {
      dutyTimer = null;
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<String> _getPlaceNameFromCoordinates(double latitude, double longitude) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, 
          longitude,
        ).timeout(Duration(seconds: 10));
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> addressParts = [];
          
          if (place.street != null && place.street!.isNotEmpty) {
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
          
          if (addressParts.isNotEmpty) {
            return addressParts.join(', ');
          }
          
          if (place.name != null && place.name!.isNotEmpty) {
            return place.name!;
          }
        }
        
        if (attempt < 2) continue;
        return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      } catch (e) {
        print('Geocoding attempt ${attempt + 1} failed: $e');
        if (attempt == 2) {
          return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }
      }
    }
    return 'Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
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

      Navigator.pop(context);

      setState(() {
        if (isCheckIn) {
          checkInLocation = position;
          checkInPlaceName = 'Fetching address...';
        } else {
          checkOutLocation = position;
          checkOutPlaceName = 'Fetching address...';
        }
      });

      _getPlaceNameFromCoordinates(
        position.latitude,
        position.longitude,
      ).then((placeName) {
        if (mounted) {
          setState(() {
            if (isCheckIn) {
              checkInPlaceName = placeName;
            } else {
              checkOutPlaceName = placeName;
            }
          });
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
                Text('RTO Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  children: List.generate(6, (index) {
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
      case 0: return 'Step 1: Check-in Selfie';
      case 1: return 'Step 2: Vehicle Photos (Min 4)';
      case 2: return 'Step 3: Duty Sheet Upload';
      case 3: return 'Step 4: Complete Duty';
      case 4: return 'Step 5: Check-out & Slip Details';
      case 5: return 'Step 6: Summary';
      default: return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 0: return _buildCheckInStep();
      case 1: return _buildVehiclePhotosStep();
      case 2: return _buildDutySheetStep();
      case 3: return _buildDutyTimerStep();
      case 4: return _buildCheckOutAndSlipStep();
      case 5: return _buildSummaryStep();
      default: return Container();
    }
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclePhotosStep() {
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
              Icon(Icons.directions_car, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text('Vehicle Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Capture minimum 4 photos of the vehicle',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: vehiclePhotos.length >= 4 ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: vehiclePhotos.length >= 4 ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  vehiclePhotos.length >= 4 ? Icons.check_circle : Icons.info,
                  color: vehiclePhotos.length >= 4 ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  '${vehiclePhotos.length}/4 photos captured',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: vehiclePhotos.length + (vehiclePhotos.length < 10 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < vehiclePhotos.length) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFFFC107), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(vehiclePhotos[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            vehiclePhotos.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: () => _takeVehiclePhoto(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFFC107), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 32, color: Color(0xFFFFC107)),
                        SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDutySheetStep() {
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
              Icon(Icons.description, color: Colors.purple[600]),
              SizedBox(width: 8),
              Text('Duty Sheet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text('Upload duty sheet picture', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 24),
          
          Center(
            child: GestureDetector(
              onTap: () => _takeDutySheetPhoto(),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFFC107), width: 2),
                ),
                child: dutySheetImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(dutySheetImagePath!), fit: BoxFit.cover),
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
                          Text('Tap to capture duty sheet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                            stopDutyTimer();
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

  Widget _buildCheckOutAndSlipStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Check-out Selfie
          Container(
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
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Slip Details Form
          Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text('Slip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Prefilled Fields (Read-only)
                  Text('Prefilled Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  SizedBox(height: 12),
                  
                  _buildReadOnlyField('Client', clientName),
                  SizedBox(height: 12),
                  _buildReadOnlyField('Branch', branchName),
                  SizedBox(height: 12),
                  _buildReadOnlyField('In-Time', formatDateTime(inTime)),
                  SizedBox(height: 12),
                  _buildReadOnlyField('Out-Time', formatDateTime(outTime)),
                  
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 16),
                  
                  // Driver-filled fields
                  Text('Fill Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  SizedBox(height: 12),
                  
                  // Work Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Work Type *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedWorkType,
                    items: workTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkType = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select work type' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // Pickup Location Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pickup Location *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedPickupLocation,
                    items: pickupLocations.map((location) {
                      return DropdownMenuItem(value: location, child: Text(location));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPickupLocation = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select pickup location' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // Drop Location Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Drop Location *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedDropLocation,
                    items: dropLocations.map((location) {
                      return DropdownMenuItem(value: location, child: Text(location));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDropLocation = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select drop location' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // RTO Name
                  TextFormField(
                    controller: rtoNameController,
                    decoration: InputDecoration(
                      labelText: 'RTO Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter RTO name' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // Chassis Number
                  TextFormField(
                    controller: chassisNumberController,
                    decoration: InputDecoration(
                      labelText: 'Chassis Number *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter chassis number' : null,
                  ),
                  SizedBox(height: 24),
                  
                  // Slip Image Upload
                  Text('Upload Slip Image *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  SizedBox(height: 12),
                  
                  GestureDetector(
                    onTap: () => _takeSlipPhoto(),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFFFC107), width: 2),
                      ),
                      child: slipImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(slipImagePath!), fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 48, color: Color(0xFFFFC107)),
                                SizedBox(height: 8),
                                Text('Tap to upload slip', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    double estimatedFare = 450.0; // This would come from backend based on work type, distance, etc.
    
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
              Icon(Icons.check_circle, color: Colors.green[600]),
              SizedBox(width: 8),
              Text('Job Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  'Job Completed Successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          _buildSummarySection('Job Details', [
            _buildSummaryRow('Client', clientName),
            _buildSummaryRow('Branch', branchName),
            _buildSummaryRow('Work Type', selectedWorkType ?? 'N/A'),
            _buildSummaryRow('Date', DateTime.now().toString().split(' ')[0]),
          ]),
          
          SizedBox(height: 20),
          
          _buildSummarySection('Time Details', [
            _buildSummaryRow('In-Time', formatDateTime(inTime)),
            _buildSummaryRow('Out-Time', formatDateTime(outTime)),
            _buildSummaryRow('Duration', formatTime(dutySeconds)),
          ]),
          
          SizedBox(height: 20),
          
          _buildSummarySection('Location Details', [
            _buildSummaryRow('Pickup', selectedPickupLocation ?? 'N/A'),
            _buildSummaryRow('Drop', selectedDropLocation ?? 'N/A'),
          ]),
          
          SizedBox(height: 20),
          
          _buildSummarySection('Vehicle Details', [
            _buildSummaryRow('RTO Name', rtoNameController.text),
            _buildSummaryRow('Chassis No.', chassisNumberController.text),
            _buildSummaryRow('Photos', '${vehiclePhotos.length} uploaded'),
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
          
          SizedBox(height: 24),
          
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
                Text('Estimated Fare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '₹${estimatedFare.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFC107),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Complete Job',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
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
                    'Payment will be processed within 24-48 hours',
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

  bool _shouldShowBottomButton() {
    if (currentStep == 0 && checkInSelfieImagePath != null && checkInLocation != null) return true;
    if (currentStep == 1 && vehiclePhotos.length >= 4) return true;
    if (currentStep == 2 && dutySheetImagePath != null) return true;
    if (currentStep == 3) return false; // Timer has its own button
    if (currentStep == 4 && 
        checkOutSelfieImagePath != null && 
        checkOutLocation != null && 
        slipImagePath != null &&
        _formKey.currentState?.validate() == true) return true;
    if (currentStep == 5) return false; // Summary has its own button
    return false;
  }

  Widget _buildBottomButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (currentStep) {
      case 0:
        buttonText = 'Continue to Vehicle Photos';
        onPressed = nextStep;
        break;
      case 1:
        buttonText = 'Continue to Duty Sheet';
        onPressed = nextStep;
        break;
      case 2:
        buttonText = 'Start Duty Timer';
        onPressed = nextStep;
        break;
      case 4:
        buttonText = 'View Summary';
        onPressed = () {
          if (_formKey.currentState?.validate() ?? false) {
            nextStep();
          }
        };
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

        await Future.delayed(Duration(milliseconds: 500));
        _getCurrentLocation(isCheckIn);
      }
    } catch (e) {
      print('Error taking selfie: $e');
    }
  }

  void _takeVehiclePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          vehiclePhotos.add(image.path);
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  void _takeDutySheetPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          dutySheetImagePath = image.path;
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  void _takeSlipPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          slipImagePath = image.path;
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }
}