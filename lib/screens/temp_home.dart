import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/campaign.dart' hide RTOWorksScreen;
import 'package:vdrivpartner/screens/rto_screen.dart';
import 'package:vdrivpartner/screens/terms_screen.dart';

class CampaignDashboard extends StatefulWidget {
  final String selectedLanguage;
  final bool showToast; 
  final String name;
  final String driverid;
  
  const CampaignDashboard({
    Key? key, 
    required this.selectedLanguage,
    this.showToast = false, 
    required this.name,
    required this.driverid,
  }) : super(key: key);

  @override
  _CampaignDashboardState createState() => _CampaignDashboardState();
}

class _CampaignDashboardState extends State<CampaignDashboard> {
  bool _isSwitchOn = false;
  String selectedLanguage = "English";
  int _selectedNavIndex = 0;
  bool _showToastBanner = true;

  Map<String, bool> isExpanded = {
    'Campaign Works': false,
    'RTO Services': false,
  };

  @override
  void initState() {
    super.initState();
    // Show toast if the parameter is true
    if (widget.showToast) {
      setState(() {
        _showToastBanner = true;
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
    // TODO: Replace with your actual FAQ navigation
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsScreen(selectedLanguage: widget.selectedLanguage)),
     );
    print('Navigate to FAQs');
    _dismissToast();
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
                  'English',
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
              120
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section - Redesigned
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
                              '${widget.name}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${widget.driverid}',
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
                              color: _isSwitchOn ? Color(0xff000000): Colors.grey[600],
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
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                TopCardsSection(),
                SizedBox(height: 24),
                
                Text(
                  'Available works',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                WorkCard(
                  title: 'Campaign Works',
                  subtitle: 'ITC Grand Chola',
                  price: '700.00 (5 hrs)',
                  icon: Icons.calendar_today,
                  slotsAvailable: 3,
                  isExpanded: isExpanded['Campaign Works']!,
                  workType: 'campaign',
                  onTap: () {
                    setState(() {
                      isExpanded['Campaign Works'] = !isExpanded['Campaign Works']!;
                      if (isExpanded['RTO Services']!) {
                        isExpanded['RTO Services'] = false;
                      }
                    });
                  },
                  slotItems: [
                    SlotItem(
                        title: 'Morning 08:00 - 13:00', isBookable: true, price: ''),
                    SlotItem(
                        title: 'Afternoon 13:00 - 18:00',
                        isBookable: true,
                        price: ''),
                    SlotItem(
                        title: 'Evening 18:00 - 23:00', isBookable: true, price: ''),
                  ],
                ),
                SizedBox(height: 16),
                WorkCard(
                  title: 'RTO Services',
                  subtitle: 'Registration and Documentation',
                  icon: Icons.assignment,
                  slotsAvailable: 2,
                  isExpanded: isExpanded['RTO Services']!,
                  workType: 'rto',
                  onTap: () {
                    setState(() {
                      isExpanded['RTO Services'] = !isExpanded['RTO Services']!;
                      if (isExpanded['Campaign Works']!) {
                        isExpanded['Campaign Works'] = false;
                      }
                    });
                  },
                  slotItems: [
                    SlotItem(
                      title: 'New Registration',
                      subtitle: 'Hyundai Showroom, Guindy • 5km\nEst. 5 - 6 hours • 1:00 PM',
                      price: '400.00',
                      isBookable: true,
                    ),
                    SlotItem(
                      title: 'Ownership Transfer',
                      subtitle: 'Maruti Showroom, Anna Nagar • 8km\nEst. 3 - 4 hours • 3:00 PM',
                      price: '350.00',
                      isBookable: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Toast Notification Banner at the top
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
                            icon: Icon(Icons.close, color: Colors.white, size: 20),
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
          currentIndex: _selectedNavIndex >= 2 ? _selectedNavIndex + 1 : _selectedNavIndex,
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
      floatingActionButton: Container(
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
            onTap: () {
              print('Job button pressed');
            },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class TopCardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: '2341',
            subtitle: 'Total Trips',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            title: '\$234',
            subtitle: 'Today Pay',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            title: '4.9 ⭐',
            subtitle: 'Ratings',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
  }) {
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
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlotItem {
  final String title;
  final String? subtitle;
  final String? price;
  final bool isBookable;

  SlotItem({
    required this.title,
    this.subtitle,
    this.price,
    required this.isBookable,
  });
}

class WorkCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? price;
  final IconData icon;
  final int slotsAvailable;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<SlotItem> slotItems;
  final String workType;

  const WorkCard({
    required this.title,
    required this.subtitle,
    this.price,
    required this.icon,
    required this.slotsAvailable,
    required this.isExpanded,
    required this.onTap,
    required this.slotItems,
    required this.workType,
  });

  @override
  _WorkCardState createState() => _WorkCardState();
}

class _WorkCardState extends State<WorkCard> {
  Set<int> _selectedSlotIndices = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFffd300)),
      ),
      color: Color(0xffFFFDF1).withOpacity(0.57),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFF1C40F),
                    child: Icon(widget.icon, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 5),
                        if (widget.price != null)
                          Text(
                            '₹${widget.price}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      Chip(
                        label: Text(
                          '${widget.slotsAvailable} available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Color(0xffFFFDF1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Color(0xffffd300)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.isExpanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xffffd300)),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ...widget.slotItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            SlotItem item = entry.value;
                            return _buildSlotItem(item, index);
                          }).toList(),
                          if (_selectedSlotIndices.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0, top: 10.0),
                                child: SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _navigateToWorkScreen(context);
                                    },
                                    child: Text(
                                      'Book ${_selectedSlotIndices.length} Slot${_selectedSlotIndices.length > 1 ? 's' : ''}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFF1C40F),
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToWorkScreen(BuildContext context) {
    if (widget.workType == 'campaign') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CampaignWorksScreen(),
        ),
      );
    } else if (widget.workType == 'rto') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RTOWorksScreen(),
        ),
      );
    }
  }

  Widget _buildSlotItem(SlotItem item, int index) {
    return Column(
      children: [
        CheckboxListTile(
          value: _selectedSlotIndices.contains(index),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedSlotIndices.add(index);
              } else {
                _selectedSlotIndices.remove(index);
              }
            });
          },
          activeColor: Color(0xffFFD300),
          checkColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: item.isBookable ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
              if (item.price != null && item.price!.isNotEmpty)
                Text(
                  '₹${item.price}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
            ],
          ),
          subtitle: item.subtitle != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      decoration: item.isBookable ? null : TextDecoration.lineThrough,
                    ),
                  ),
                )
              : null,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (index < widget.slotItems.length - 1)
          Divider(
            color: Color(0xffffd300),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}