import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'permanent_home.dart';

// Job State Manager to persist job progress
class JobStateManager {
  static final JobStateManager _instance = JobStateManager._internal();
  factory JobStateManager() => _instance;
  JobStateManager._internal();

  Map<String, JobProgress> _jobStates = {};

  JobProgress? getJobProgress(String jobId) {
    return _jobStates[jobId];
  }

  void saveJobProgress(String jobId, JobProgress progress) {
    _jobStates[jobId] = progress;
  }

  void removeJobProgress(String jobId) {
    _jobStates.remove(jobId);
  }

  bool hasProgress(String jobId) {
    return _jobStates.containsKey(jobId);
  }
}

// Job Progress Model
class JobProgress {
  int currentStep;
  String? checkInSelfieImagePath;
  String? checkOutSelfieImagePath;
  Position? checkInLocation;
  Position? checkOutLocation;
  String? checkInPlaceName;
  String? checkOutPlaceName;
  Timer? dutyTimer;
  int dutySeconds;
  DateTime? timerStartTime;
  List<String> vehiclePhotos;

  JobProgress({
    this.currentStep = 0,
    this.checkInSelfieImagePath,
    this.checkOutSelfieImagePath,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInPlaceName,
    this.checkOutPlaceName,
    this.dutyTimer,
    this.dutySeconds = 0,
    this.timerStartTime,
    List<String>? vehiclePhotos,
  }) : vehiclePhotos = vehiclePhotos ?? [];
}

// ==================== ACCEPTED JOBS LIST SCREEN ====================
class AcceptedJobsListScreen extends StatefulWidget {
  final List<AcceptedJob> acceptedJobs;
  final Function(AcceptedJob) onJobRemoved;

  const AcceptedJobsListScreen({
    Key? key,
    required this.acceptedJobs,
    required this.onJobRemoved,
  }) : super(key: key);

  @override
  State<AcceptedJobsListScreen> createState() => _AcceptedJobsListScreenState();
}

class _AcceptedJobsListScreenState extends State<AcceptedJobsListScreen> {
  final JobStateManager _stateManager = JobStateManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD300),
        elevation: 0,
        title: Text(
          'My Jobs',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: widget.acceptedJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No active jobs',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Accept jobs from the home screen',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.acceptedJobs.length,
              itemBuilder: (context, index) {
                final job = widget.acceptedJobs[index];
                final hasProgress = _stateManager.hasProgress(job.id);
                final progress = _stateManager.getJobProgress(job.id);

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampaignWorksScreen(
                              acceptedJob: job,
                              onJobCompleted: () {
                                widget.onJobRemoved(job);
                              },
                            ),
                          ),
                        );
                        setState(() {}); // Refresh to show updated progress
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16, color: Colors.black54),
                                    SizedBox(width: 8),
                                    Text(
                                      job.date,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: job.service == 'Pickup'
                                        ? Colors.green.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    job.service,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: job.service == 'Pickup'
                                          ? Colors.green.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              job.companyName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 16, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  job.time,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_outline,
                                    size: 16, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  job.customerName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (hasProgress && progress != null) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Color(0xFFFFC107), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.play_circle_outline,
                                        size: 16, color: Color(0xFFFFC107)),
                                    SizedBox(width: 8),
                                    Text(
                                      _getProgressText(progress),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  hasProgress ? 'Continue →' : 'Tap to start →',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFFFC107),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getProgressText(JobProgress progress) {
    switch (progress.currentStep) {
      case 0:
        return 'Ready to start';
      case 1:
        return 'Check-in pending';
      case 2:
        return 'Vehicle photos pending';
      case 3:
        return 'Duty in progress';
      case 4:
        return 'Check-out pending';
      case 5:
        return 'Slip details pending';
      case 6:
        return 'Review summary';
      default:
        return 'In progress';
    }
  }
}

// ==================== CAMPAIGN WORKS SCREEN ====================
class CampaignWorksScreen extends StatefulWidget {
  final AcceptedJob acceptedJob;
  final VoidCallback onJobCompleted;

  const CampaignWorksScreen({
    Key? key,
    required this.acceptedJob,
    required this.onJobCompleted,
  }) : super(key: key);

  @override
  _CampaignWorksScreenState createState() => _CampaignWorksScreenState();
}

class _CampaignWorksScreenState extends State<CampaignWorksScreen> with WidgetsBindingObserver {
  final JobStateManager _stateManager = JobStateManager();
  late JobProgress _progress;
  final _slipFormKey = GlobalKey<FormState>();
  final TextEditingController _vehicleNumberController = TextEditingController();
  String? _selectedPickupLocation;
  String? _selectedDropLocation;
  String? _slipImagePath;
  final List<String> _pickupLocations = [
    'Hyundai Showroom, Guindy',
    'Customer Location - Anna Nagar',
    'Customer Location - T Nagar',
    'Warehouse - Ambattur',
  ];
  final List<String> _dropLocations = [
    'RTO Office - Guindy',
    'RTO Office - Ashok Nagar',
    'Customer Location',
    'Showroom',
  ];

  final List<String> stepTitles = [
    'Trip Details',
    'Check-in',
    'Vehicle Photos',
    'Duty Timer',
    'Check-out',
    'Slip Details',
    'Summary'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load existing progress or create new
    final existingProgress = _stateManager.getJobProgress(widget.acceptedJob.id);
    if (existingProgress != null) {
      _progress = existingProgress;
      
      // Restart timer if it was running
      if (_progress.currentStep == 3 && _progress.timerStartTime != null) {
        final elapsed = DateTime.now().difference(_progress.timerStartTime!);
        _progress.dutySeconds += elapsed.inSeconds;
        _startDutyTimer();
      }
    } else {
      _progress = JobProgress();
    }

    // Prefill vehicle number if available
    _vehicleNumberController.text = widget.acceptedJob.vehicleNumber;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Save progress before disposing but don't cancel timer
    _saveProgress();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveProgress();
    } else if (state == AppLifecycleState.resumed) {
      if (_progress.currentStep == 3 && _progress.timerStartTime != null) {
        setState(() {});
      }
    }
  }

  void _saveProgress() {
    _stateManager.saveJobProgress(widget.acceptedJob.id, _progress);
  }

  void _nextStep() {
    if (_progress.currentStep < stepTitles.length - 1) {
      setState(() {
        _progress.currentStep++;
        _saveProgress();
      });
    }
  }

  void _startDutyTimer() {
    _progress.timerStartTime = DateTime.now();
    _progress.dutyTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _progress.dutySeconds++;
        });
      }
    });
    _saveProgress();
  }

  String _formatTime(int seconds) {
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

      String placeName = await _getPlaceNameFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Navigator.pop(context);

      setState(() {
        if (isCheckIn) {
          _progress.checkInLocation = position;
          _progress.checkInPlaceName = placeName;
        } else {
          _progress.checkOutLocation = position;
          _progress.checkOutPlaceName = placeName;
        }
        _saveProgress();
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
    return WillPopScope(
      onWillPop: () async {
        _saveProgress();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Color(0xFFFFC107),
          elevation: 0,
          title: Text('VDriv', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _saveProgress();
              Navigator.pop(context);
            },
          ),
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
                    children: List.generate(7, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _progress.currentStep ? Color(0xFFFFC107) : Colors.grey[300],
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
      ),
    );
  }

  String _getCurrentStepLabel() {
    switch (_progress.currentStep) {
      case 0: return 'Step 1: View Trip Details';
      case 1: return 'Step 2: Check-in (Selfie + Location)';
      case 2: return 'Step 3: Vehicle Photos (Min 4)';
      case 3: return 'Step 4: Duty Timer';
      case 4: return 'Step 5: Check-out (Selfie + Location)';
      case 5: return 'Step 6: Slip Details';
      case 6: return 'Step 7: View Summary & Payment';
      default: return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_progress.currentStep) {
      case 0: return _buildTripDetailsStep();
      case 1: return _buildCheckInStep();
      case 2: return _buildVehiclePhotosStep();
      case 3: return _buildDutyTimerStep();
      case 4: return _buildCheckOutStep();
      case 5: return _buildSlipDetailsStep();
      case 6: return _buildTripSummaryStep();
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
          _buildDetailCard(Icons.local_taxi, 'Service', widget.acceptedJob.service),
          SizedBox(height: 16),
          _buildDetailCard(Icons.business, 'Branch', widget.acceptedJob.companyName),
          SizedBox(height: 16),
          _buildDetailCard(Icons.access_time, 'Time', widget.acceptedJob.time),
          SizedBox(height: 16),
          _buildDetailCard(Icons.person, 'Customer', widget.acceptedJob.customerName),
          SizedBox(height: 16),
          _buildDetailCard(Icons.phone, 'Customer Contact', widget.acceptedJob.customerPhone),
          SizedBox(height: 16),
          _buildDetailCard(Icons.directions_car, 'Vehicle', widget.acceptedJob.vehicleNumber),
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
                    Text('Customer Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Text(widget.acceptedJob.location, style: TextStyle(color: Colors.grey[700])),
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
                child: _progress.checkInSelfieImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(_progress.checkInSelfieImagePath!), fit: BoxFit.cover),
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
              color: _progress.checkInLocation != null ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _progress.checkInLocation != null ? Colors.green : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _progress.checkInLocation != null ? Icons.check_circle : Icons.location_on,
                      color: _progress.checkInLocation != null ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      _progress.checkInLocation != null ? 'Location Captured' : 'Capture Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_progress.checkInLocation != null) ...[
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
                            _progress.checkInPlaceName ?? 'Loading address...',
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
                      Text('${_progress.checkInLocation!.latitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Longitude:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('${_progress.checkInLocation!.longitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accuracy:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('±${_progress.checkInLocation!.accuracy.toStringAsFixed(1)}m', style: TextStyle(fontSize: 12)),
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
          Text('Capture minimum 4 photos of the vehicle', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _progress.vehiclePhotos.length >= 4 ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _progress.vehiclePhotos.length >= 4 ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _progress.vehiclePhotos.length >= 4 ? Icons.check_circle : Icons.info,
                  color: _progress.vehiclePhotos.length >= 4 ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  '${_progress.vehiclePhotos.length}/4 photos captured',
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
            itemCount: _progress.vehiclePhotos.length + (_progress.vehiclePhotos.length < 10 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _progress.vehiclePhotos.length) {
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
                          File(_progress.vehiclePhotos[index]),
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
                            _progress.vehiclePhotos.removeAt(index);
                            _saveProgress();
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
                  onTap: _takeVehiclePhoto,
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
                        Text('Add Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  void _takeVehiclePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _progress.vehiclePhotos.add(image.path);
          _saveProgress();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                child: _progress.checkOutSelfieImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(_progress.checkOutSelfieImagePath!), fit: BoxFit.cover),
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
              color: _progress.checkOutLocation != null ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _progress.checkOutLocation != null ? Colors.green : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _progress.checkOutLocation != null ? Icons.check_circle : Icons.location_on,
                      color: _progress.checkOutLocation != null ? Colors.green : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      _progress.checkOutLocation != null ? 'Location Captured' : 'Capture Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_progress.checkOutLocation != null) ...[
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
                            _progress.checkOutPlaceName ?? 'Loading address...',
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
                      Text('${_progress.checkOutLocation!.latitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Longitude:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('${_progress.checkOutLocation!.longitude.toStringAsFixed(6)}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accuracy:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text('±${_progress.checkOutLocation!.accuracy.toStringAsFixed(1)}m', style: TextStyle(fontSize: 12)),
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
            _progress.dutyTimer == null ? 'Start your duty timer' : 'Your duty is in progress',
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
                    _formatTime(_progress.dutySeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  _progress.dutyTimer != null ? 'Duty in progress' : 'Ready to start',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _progress.dutyTimer != null
                        ? () {
                            _progress.dutyTimer?.cancel();
                            setState(() {
                              _progress.dutyTimer = null;
                              _progress.timerStartTime = null;
                              _saveProgress();
                            });
                            _nextStep();
                          }
                        : () {
                            _startDutyTimer();
                            setState(() {});
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _progress.dutyTimer != null ? Colors.red : Color(0xFFFFC107),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _progress.dutyTimer != null ? Icons.stop : Icons.play_arrow,
                          color: _progress.dutyTimer != null ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _progress.dutyTimer != null ? 'End Duty' : 'Start Duty',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _progress.dutyTimer != null ? Colors.white : Colors.black,
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
    double totalHours = _progress.dutySeconds / 3600.0;

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
            width: double.infinity,
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
            _buildSummaryRow('Location', widget.acceptedJob.companyName),
            _buildSummaryRow('Customer', widget.acceptedJob.customerName),
            _buildSummaryRow('Date', widget.acceptedJob.date),
            _buildSummaryRow('Service Type', widget.acceptedJob.service),
          ]),
          SizedBox(height: 20),
          _buildSummarySection('Time Details', [
            _buildSummaryRow('Duration', _formatTime(_progress.dutySeconds)),
            _buildSummaryRow('Total Hours', '${totalHours.toStringAsFixed(2)} hrs'),
          ]),
          SizedBox(height: 20),
          _buildSummarySection('Location Verification', [
            _buildSummaryRow('Check-in', _progress.checkInLocation != null ? '✓ Verified' : '✗ Not captured'),
            if (_progress.checkInPlaceName != null)
              _buildSummaryRowFullWidth('Check-in Location', _progress.checkInPlaceName!),
            _buildSummaryRow('Check-out', _progress.checkOutLocation != null ? '✓ Verified' : '✗ Not captured'),
            if (_progress.checkOutPlaceName != null)
              _buildSummaryRowFullWidth('Check-out Location', _progress.checkOutPlaceName!),
          ]),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFFFC107), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, color: Color(0xFFFFC107), size: 24),
                SizedBox(width: 12),
                Text(
                  'Payment Processing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
                  onPressed: () {
                    _stateManager.removeJobProgress(widget.acceptedJob.id);
                    widget.onJobCompleted();
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
    if (_progress.currentStep == 0) return true;
    if (_progress.currentStep == 1 && _progress.checkInSelfieImagePath != null && _progress.checkInLocation != null) return true;
    if (_progress.currentStep == 2) return _progress.vehiclePhotos.length >= 4;
    if (_progress.currentStep == 3) return false;
    if (_progress.currentStep == 4 && _progress.checkOutSelfieImagePath != null && _progress.checkOutLocation != null) return true;
    if (_progress.currentStep == 5) {
      // Validate slip details: vehicle number and slip image, and at least one of pickup/drop set
      final vehicleOk = _vehicleNumberController.text.trim().isNotEmpty;
      final imgOk = _slipImagePath != null;
      final locOk = (widget.acceptedJob.service == 'Pickup')
          ? (_selectedPickupLocation != null && _selectedPickupLocation!.isNotEmpty)
          : (_selectedDropLocation != null && _selectedDropLocation!.isNotEmpty);
      return vehicleOk && imgOk && locOk;
    }
    if (_progress.currentStep == 6) return false;
    return false;
  }

  Widget _buildBottomButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (_progress.currentStep) {
      case 0:
        buttonText = 'Start Journey';
        onPressed = _nextStep;
        break;
      case 1:
        buttonText = 'Continue to Vehicle Photos';
        onPressed = _nextStep;
        break;
      case 2:
        buttonText = 'Continue to Duty Timer';
        onPressed = _nextStep;
        break;
      case 4:
        buttonText = 'Continue to Slip Details';
        onPressed = _nextStep;
        break;
      case 5:
        buttonText = 'View Summary';
        onPressed = _nextStep;
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
            _progress.checkInSelfieImagePath = image.path;
          } else {
            _progress.checkOutSelfieImagePath = image.path;
          }
          _saveProgress();
        });

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

  Future<void> _takeSlipImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _slipImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing slip: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSlipDetailsStep() {
    final String clientName = 'Hyundai Motors';
    final String branchName = widget.acceptedJob.companyName;
    final bool isPickup = widget.acceptedJob.service.toLowerCase() == 'pickup';

    // Fix one location depending on service
    final String fixedLocation = isPickup ? branchName : 'Customer Location';

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Form(
        key: _slipFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.orange[700]),
                SizedBox(width: 8),
                Text('Slip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailCard(Icons.business, 'Client', clientName),
            SizedBox(height: 12),
            _buildDetailCard(Icons.store_mall_directory, 'Branch', branchName),
            SizedBox(height: 12),
            _buildDetailCard(Icons.local_taxi, 'Service', widget.acceptedJob.service),
            SizedBox(height: 16),

            // Locations
            Text('Locations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            if (isPickup) ...[
              _buildDropdown(
                label: 'Pickup Location',
                value: _selectedPickupLocation,
                items: _pickupLocations,
                onChanged: (v) => setState(() => _selectedPickupLocation = v),
              ),
              SizedBox(height: 12),
              _buildFixedField('Drop Location', fixedLocation),
            ] else ...[
              _buildFixedField('Pickup Location', 'Customer Location'),
              SizedBox(height: 12),
              _buildDropdown(
                label: 'Drop Location',
                value: _selectedDropLocation,
                items: _dropLocations,
                onChanged: (v) => setState(() => _selectedDropLocation = v),
              ),
            ],

            SizedBox(height: 16),
            Text('Vehicle Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            TextFormField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter vehicle number' : null,
            ),

            SizedBox(height: 16),
            Text('Slip Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _takeSlipImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFFC107), width: 2),
                ),
                child: _slipImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(_slipImagePath!), fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 32, color: Color(0xFFFFC107)),
                            SizedBox(height: 8),
                            Text('Tap to upload slip image', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(height: 8),
            Text('Payment will be processed after verification', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(border: OutlineInputBorder()),
          validator: (v) => (v == null || v.isEmpty) ? 'Select $label' : null,
        ),
      ],
    );
  }

  Widget _buildFixedField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
