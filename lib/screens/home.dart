import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/campaign.dart' hide RTOWorksScreen;
import 'package:vdrivpartner/screens/rto_screen.dart';

class CampaignDashboard extends StatefulWidget {
  final String selectedLanguage;
  const CampaignDashboard({Key? key, required this.selectedLanguage}) : super(key: key);
  

  @override
  _CampaignDashboardState createState() => _CampaignDashboardState();
}

class _CampaignDashboardState extends State<CampaignDashboard> {
  bool _isSwitchOn = false;
  String selectedLanguage = "English";
  int _selectedNavIndex = 0;

  // A map to track the expanded state of each card
  Map<String, bool> isExpanded = {
    'Campaign Works': false,
    'RTO Services': false,
  };

  void _onNavItemTapped(int index) {
    if (index == 2) return; // Skip center button index
    setState(() {
      _selectedNavIndex = index > 2 ? index - 1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD300),
        elevation: 0,
        title: Text(
          'VDriv',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.language, color: Colors.black),
              SizedBox(width: 4),
              Text(
                'English',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Welcome Zaid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: _isSwitchOn,
                    onChanged: (bool value) {
                      setState(() {
                        _isSwitchOn = value;
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    activeColor: Colors.transparent,
                    activeTrackColor: Color(0xffFFD300),
                    inactiveTrackColor: const Color.fromARGB(255, 201, 200, 200),
                    thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Top Cards Section
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
            // Campaign Works Card
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
            // RTO Services Card
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
        margin: EdgeInsets.only(top: 30), // Moved down into the bottom nav bar
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
  final String workType; // 'campaign' or 'rto'

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
  Set<int> _selectedSlotIndices = {}; // Changed to Set to allow multiple selections

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
            // The expandable content
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

// Placeholder screens - replace with your actual implementations
