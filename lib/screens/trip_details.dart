import 'package:flutter/material.dart';

class TripDetailsScreen extends StatefulWidget {
  final String selectedLanguage;
  const TripDetailsScreen({super.key, required this.selectedLanguage});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  // Controllers for each digit of the Trip ID
  final TextEditingController _digit1Controller = TextEditingController();
  final TextEditingController _digit2Controller = TextEditingController();
  final TextEditingController _digit3Controller = TextEditingController();
  final TextEditingController _digit4Controller = TextEditingController();

  // Flag to track if the button should be enabled
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to each controller to check for changes
    _digit1Controller.addListener(_checkButtonStatus);
    _digit2Controller.addListener(_checkButtonStatus);
    _digit3Controller.addListener(_checkButtonStatus);
    _digit4Controller.addListener(_checkButtonStatus);

    // No need to add listeners to focus nodes if using ValueListenableBuilder
  }

  @override
  void dispose() {
    // Dispose the controllers and focus nodes to free up resources
    _digit1Controller.dispose();
    _digit2Controller.dispose();
    _digit3Controller.dispose();
    _digit4Controller.dispose();
   
    super.dispose();
  }

  // Method to check if all four text fields are filled
  void _checkButtonStatus() {
    setState(() {
      _isButtonEnabled = _digit1Controller.text.length == 1 &&
          _digit2Controller.text.length == 1 &&
          _digit3Controller.text.length == 1 &&
          _digit4Controller.text.length == 1;
    });
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
        title: const Text(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outstation (One Way)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.black),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ' TVH Apartments, Kundrathur road',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: const [
                        Icon(Icons.crop_square, color: Colors.black),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ' Pallavaram, Chennai',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 40, color: Color(0xffffd300)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Mr. Yazhan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '9444458070',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'TVH Apartments, Kundrathur road',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '\$ 450.0',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Enter 4 digit Trip ID',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTripIdBox(_digit1Controller),
                  _buildTripIdBox(_digit2Controller),
                  _buildTripIdBox(_digit3Controller),
                  _buildTripIdBox(_digit4Controller),
                ],
              ),
              const SizedBox(height: 215),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                          // Action to perform when the button is enabled and pressed
                          // e.g., print the full trip ID
                          String tripId = _digit1Controller.text +
                              _digit2Controller.text +
                              _digit3Controller.text +
                              _digit4Controller.text;
                          print('Trip ID entered: $tripId');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Start ride with Trip ID: $tripId')),
                          );
                        }
                      : null, // If _isButtonEnabled is false, onPressed is null, disabling the button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9C016),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Set the disabled color for the button
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Start Ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripIdBox(TextEditingController controller) {
  return Container(
    width: 55,
    height: 60,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        counterText: "", // Hide the default character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFD300), width: 2),
        ),
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          FocusScope.of(context).nextFocus();
        }
        _checkButtonStatus();
      },
    ),
  );
}}