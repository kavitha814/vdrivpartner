import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'job_list.dart';

// ==================== JOB MODEL ====================
class AcceptedJob {
  final String id; // Unique identifier
  final String date;
  final DateTime dateSort;
  final String service;
  final String companyName;
  final String time;
  final String location;
  final String customerName;
  final String customerPhone;
  final String vehicleNumber;

  AcceptedJob({
    required this.id,
    required this.date,
    required this.dateSort,
    required this.service,
    required this.companyName,
    required this.time,
    required this.location,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleNumber,
  });
}

// ==================== MAIN DASHBOARD ====================
class VDriverDashboard extends StatefulWidget {
  final String selectedLanguage;
  final bool showToast;
  final String name;
  final String driverid;

  const VDriverDashboard({
    Key? key,
    required this.selectedLanguage,
    this.showToast = false,
    required this.name,
    required this.driverid,
  }) : super(key: key);

  @override
  State<VDriverDashboard> createState() => _VDriverDashboardState();
}

class _VDriverDashboardState extends State<VDriverDashboard> {
  bool _isSwitchOn = false;
  int _selectedNavIndex = 0;
  bool _showToastBanner = false;
  List<AcceptedJob> acceptedJobs = [];

  @override
  void initState() {
    super.initState();
    if (widget.showToast) {
      setState(() {
        _showToastBanner = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 2) return;
    setState(() {
      _selectedNavIndex = index > 2 ? index - 1 : index;
    });
  }

  void _dismissToast() {
    setState(() {
      _showToastBanner = false;
    });
  }

  void _navigateToFAQ() {
    print('Navigate to FAQs');
    _dismissToast();
  }

  void _onJobAccepted(AcceptedJob job) {
    setState(() {
      acceptedJobs.add(job);
    });
  }

  void _openJobsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (acceptedJobs.isNotEmpty) {
            List<AcceptedJob> sorted = List.from(acceptedJobs);
            sorted.sort((a, b) => b.dateSort.compareTo(a.dateSort));
            final latestJob = sorted.first;
            return CampaignWorksScreen(
              acceptedJob: latestJob,
              onJobCompleted: () {
                setState(() {
                  acceptedJobs.remove(latestJob);
                });
              },
            );
          }
          return AcceptedJobsListScreen(
            acceptedJobs: acceptedJobs,
            onJobRemoved: (job) {
              setState(() {
                acceptedJobs.remove(job);
              });
            },
          );
        },
      ),
    );
    
    // Refresh the state when returning from jobs screen
    if (result != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD300),
        elevation: 0,
        toolbarHeight: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'VDriv',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, color: Colors.black, size: 18),
                SizedBox(width: 6),
                Text(
                  widget.selectedLanguage,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              _showToastBanner ? 90 : 24,
              20,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFDF1),
                        Color(0xFFFFF9E6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFFFD300).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFD300).withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFD300).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.driverid,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _isSwitchOn ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isSwitchOn
                                  ? Color(0xff000000)
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Transform.scale(
                            scale: 1.1,
                            child: Switch(
                              value: _isSwitchOn,
                              onChanged: (bool value) {
                                setState(() {
                                  _isSwitchOn = value;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              activeColor: Colors.white,
                              activeTrackColor: Color(0xFFffd300),
                              inactiveTrackColor: Colors.grey[400],
                              inactiveThumbColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('2341', 'Total Trips'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('\$234', 'Today Pay'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCardWithStar('4.9', 'Ratings'),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Available Works Section
                Text(
                  'Available works',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16),

                // Campaign Works Widget
                CampaignWorksWidget(
                  onJobAccepted: _onJobAccepted,
                ),

                SizedBox(height: 16),

                // RTO Services Widget
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFDF3),
                    border: Border.all(color: Color(0xFFE5C100), width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFFE5C100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RTO Services',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Registration and',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Documentation',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
          
          // Toast Notification Banner
          if (_showToastBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6C63FF).withOpacity(0.95),
                      Color(0xFF5A52E0).withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToFAQ,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.stars_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unlock Premium Benefits',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Become a Permanent Driver to earn more!',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.white, size: 20),
                            onPressed: _dismissToast,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF1C40F),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedNavIndex >= 2
              ? _selectedNavIndex + 1
              : _selectedNavIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withOpacity(0.6),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          onTap: _onNavItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(width: 60),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            margin: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 0,
                  spreadRadius: 3,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(35),
                onTap: _openJobsScreen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (acceptedJobs.isNotEmpty)
            Positioned(
              right: 0,
              top: 20,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '${acceptedJobs.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 0,
      color: Color(0xffFFFDF1).withOpacity(0.57),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFF1C40F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardWithStar(String value, String label) {
    return Card(
      elevation: 0,
      color: Color(0xffFFFDF1).withOpacity(0.57),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFF1C40F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '⭐',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CAMPAIGN WORKS WIDGET ====================
class CampaignWorksWidget extends StatefulWidget {
  final Function(AcceptedJob) onJobAccepted;

  const CampaignWorksWidget({
    Key? key,
    required this.onJobAccepted,
  }) : super(key: key);

  @override
  State<CampaignWorksWidget> createState() => _CampaignWorksWidgetState();
}

class _CampaignWorksWidgetState extends State<CampaignWorksWidget> {
  bool isExpanded = false;

  final List<Map<String, dynamic>> jobs = [
    {
      'id': 'job_001',
      'date': '14 Oct 2025',
      'dateSort': DateTime(2025, 10, 14, 10, 0),
      'service': 'Pickup',
      'companyName': 'Hyundai Showroom, Guindy',
      'time': '10:00 AM - 1:00 PM',
      'location': 'No. 63, Mount Road, Guindy, Chennai - 600032',
      'customerName': 'Rajesh Kumar',
      'customerPhone': '+919876543210',
      'vehicleNumber': 'TN 01 AB 1234',
      'isExpanded': false,
      'isAccepted': false,
      'hasDialed': false,
    },
    {
      'id': 'job_002',
      'date': '14 Oct 2025',
      'dateSort': DateTime(2025, 10, 14, 16, 0),
      'service': 'Drop',
      'companyName': 'Hyundai Showroom, Guindy',
      'time': '4:00 PM - 7:00 PM',
      'location': 'No. 63, Mount Road, Guindy, Chennai - 600032',
      'customerName': 'Priya Sharma',
      'customerPhone': '+919876543211',
      'vehicleNumber': 'TN 02 CD 5678',
      'isExpanded': false,
      'isAccepted': false,
      'hasDialed': false,
    },
    {
      'id': 'job_003',
      'date': '15 Oct 2025',
      'dateSort': DateTime(2025, 10, 15, 9, 0),
      'service': 'Pickup',
      'companyName': 'Hyundai Showroom, Guindy',
      'time': '9:00 AM - 12:00 PM',
      'location': 'No. 63, Mount Road, Guindy, Chennai - 600032',
      'customerName': 'Arun Patel',
      'customerPhone': '+919876543212',
      'vehicleNumber': 'TN 03 EF 9012',
      'isExpanded': false,
      'isAccepted': false,
      'hasDialed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    jobs.sort((a, b) => a['dateSort'].compareTo(b['dateSort']));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFDF3),
        border: Border.all(color: Color(0xFFE5C100), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFE5C100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campaign Works',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hyundai Showroom, Guindy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '₹700.00 (3 hrs)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return _buildJobCard(index);
              },
            ),
        ],
      ),
    );
  }
  

  Widget _buildJobCard(int index) {
    final job = jobs[index];
    final bool jobExpanded = job['isExpanded'] as bool;
    final bool isAccepted = job['isAccepted'] as bool;
    final bool hasDialed = job['hasDialed'] as bool;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5C100), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                jobs[index]['isExpanded'] = !jobExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                            job['date'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: job['service'] == 'Pickup'
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          job['service'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: job['service'] == 'Pickup'
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job['companyName'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        job['time'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Icon(
                      jobExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black38,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (jobExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Customer: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        job['customerName'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.directions_car,
                          size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Vehicle: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        job['vehicleNumber'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (!isAccepted)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                jobs[index]['isAccepted'] = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE5C100),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Accept Duty',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showRejectDialog(index, job);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(
                                  color: Colors.red.shade700, width: 1.5),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isAccepted && !hasDialed)
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: Colors.blue.shade700),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please call the customer to confirm the duty',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _callCustomer(index, job['customerPhone']);
                            },
                            icon: Icon(Icons.phone, size: 20),
                            label: Text(
                              'Call ${job['customerName']}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isAccepted && hasDialed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _confirmCustomer(index, job);
                        },
                        icon: Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          'Customer Confirmed / Okay',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE5C100),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
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

  Future<void> _callCustomer(int index, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        setState(() {
          jobs[index]['hasDialed'] = true;
        });
      } else {
        _showErrorDialog('Could not launch phone dialer');
      }
    } catch (e) {
      _showErrorDialog('Failed to make call: $e');
    }
  }

  void _showRejectDialog(int index, Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reject Duty'),
          content: Text(
              'Are you sure you want to reject the duty for ${job['companyName']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  jobs.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Duty rejected'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Reject',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmCustomer(int index, Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duty Confirmed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your duty has been confirmed successfully!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              _buildConfirmationDetail('Company', job['companyName']),
              _buildConfirmationDetail('Customer', job['customerName']),
              _buildConfirmationDetail('Service', job['service']),
              _buildConfirmationDetail(
                  'Date & Time', '${job['date']}, ${job['time']}'),
              _buildConfirmationDetail('Vehicle', job['vehicleNumber']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                
                // Create AcceptedJob object
                AcceptedJob acceptedJob = AcceptedJob(
                  id: job['id'],
                  date: job['date'],
                  dateSort: job['dateSort'],
                  service: job['service'],
                  companyName: job['companyName'],
                  time: job['time'],
                  location: job['location'],
                  customerName: job['customerName'],
                  customerPhone: job['customerPhone'],
                  vehicleNumber: job['vehicleNumber'],
                );
                
                // Call the callback to add job to dashboard
                widget.onJobAccepted(acceptedJob);
                
                setState(() {
                  jobs.removeAt(index);
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Duty confirmed and added to your bookings'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}