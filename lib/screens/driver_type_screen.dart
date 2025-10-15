import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/driver_information.dart';

// Assuming DriverInformationScreen is a valid screen to navigate to
// import 'driver_information_screen.dart'; 

class DriverTypeScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;
  

  const DriverTypeScreen({
    Key? key,
    required this.selectedLanguage,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _DriverTypeScreenState createState() => _DriverTypeScreenState();
}

class _DriverTypeScreenState extends State<DriverTypeScreen> {
  String? _selectedDriverType;
  final List<String> _driverTypes = ['Temporary Driver', 'Permanent Driver'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Wave background
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: const Color(0xFFFFD300),
              height: MediaQuery.of(context).size.height * 0.45,
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 380), // Responsive spacing
                  const Text(
                    'Select Driver Type',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please select your driver type to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Driver Type Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select Driver Type'),
                        value: _selectedDriverType,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDriverType = newValue;
                          });
                        },
                        items: _driverTypes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDriverType != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverInformationScreen(
                                    selectedLanguage: widget.selectedLanguage,
                                    phoneNumber: widget.phoneNumber,
                                  ),
                                ),
                              );
                              print('Selected driver type: $_selectedDriverType');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the same WaveClipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.85);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.9);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Placeholder for DriverInformationScreen
// class DriverInformationScreen extends StatelessWidget {
//   final String selectedLanguage;
//   final String phoneNumber;

//   const DriverInformationScreen({
//     Key? key,
//     required this.selectedLanguage,
//     required this.phoneNumber,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Driver Information')),
//       body: Center(
//         child: Text('This is the next screen.'),
//       ),
//     );
//   }
// }