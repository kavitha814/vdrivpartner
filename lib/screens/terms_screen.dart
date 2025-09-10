import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/faq_screen.dart';
class TermsScreen extends StatefulWidget {
  final String selectedLanguage;
  
  const TermsScreen({Key? key, required this.selectedLanguage}) : super(key: key);

  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 10.0 : 8.0,
      width: isActive ? 10.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey[400],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'VDriv',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFFFD300),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  widget.selectedLanguage,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Choose a VDriv location to\ncomplete your signup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 250,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('lib/images/map.webp', fit: BoxFit.cover),
            ),
            const _LocationCard(
              index: 1,
              title: 'MK stores',
              address: 'Raghupathi nagar street, Meenambakkam,\nChennai - 600061',
            ),
            const Divider(color: Color(0xFFFFD300)),
            const _LocationCard(
              index: 2,
              title: 'MK stores',
              address: 'Raghupathi nagar street, Meenambakkam,\nChennai - 600061',
            ),
            const SizedBox(height: 10),
            // Swipeable Info Box
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // PageView for swipeable content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        // Page 1: Document Requirements
                        Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 16,bottom: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Please bring these documents when you come\nto onboarding office:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('- Original Driver\'s License (with >1 year exp)'),
                              Text('- Original Aadhar Card'),
                            ],
                          ),
                        ),
                        // Page 2: Bank Transfer Info
                        Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 16,bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bank Transfer will be done on daily basis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('- Except Saturday and Sunday'),
                              Text('- Except Bank Holidays'),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bank Transfer will be done on daily basis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('- Except Saturday and Sunday'),
                              Text('- Except Bank Holidays'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Page Indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _buildPageIndicator(i == _currentPage),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
           Center(
             child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FAQScreen(selectedLanguage: widget.selectedLanguage,)),
                  );
                  // Handle button press
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(350, 55),
                  backgroundColor: const Color(0xFFFFD300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
           ),
           const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final int index;
  final String title;
  final String address;

  const _LocationCard({
    required this.index,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFD300),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, color: Color(0xFFFFD300), size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}