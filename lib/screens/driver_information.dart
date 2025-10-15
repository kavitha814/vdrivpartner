import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vdrivpartner/screens/temp_home.dart'; // Import the package


class DriverInformationScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;
  
  
  const DriverInformationScreen({Key? key, required this.selectedLanguage, required this.phoneNumber}) : super(key: key);

  @override
  State<DriverInformationScreen> createState() =>
      _DriverInformationScreenState();
}

class _DriverInformationScreenState
    extends State<DriverInformationScreen> {
  // State variables to store the selected file paths
  String? licenseFileName;
  String? aadharFileName;
  String? passbookFileName;
  bool _agreedToTerms = false;

  Future<void> _pickFile(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Allow image and PDF files
    );

    if (result != null) {
      setState(() {
        final fileName = result.files.single.name;
        if (documentType == 'license') {
          licenseFileName = fileName;
        } else if (documentType == 'aadhar') {
          aadharFileName = fileName;
        } else if (documentType == 'passbook') {
          passbookFileName = fileName;
        }
      });
      // Here you can handle the file, for example, upload it to a server.
      // print('Selected file path: ${result.files.single.path}');
    } else {
      // User canceled the picker
    }
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Driver Information Form',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Enter your Name'),
                      const SizedBox(height: 16),
                      _buildTextField('Enter your Mobile number'),
                      const SizedBox(height: 16),
                      _buildTextField('Enter your adhar number'),
                      const SizedBox(height: 16),
                      _buildTextField('Enter your account number'),
                      const SizedBox(height: 16),
                      _buildTextField('Enter IFSC code'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildUploadButton('Upload license', () => _pickFile('license'),
                              licenseFileName),
                              SizedBox(width: 16),
                          _buildUploadButton('Upload aadhar card',
                              () => _pickFile('aadhar'), aadharFileName),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildUploadButton(
                        'Upload bank passbook',
                        () => _pickFile('passbook'),
                        passbookFileName,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _agreedToTerms = value!;
                              });
                            },
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'I agree to the terms and confirm that the above information is true to the best of my knowledge',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CampaignDashboard(selectedLanguage: widget.selectedLanguage, showToast: true, name: "Zaid", driverid: "V123"),
                                ),
                              );
                              
},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildTextField(String labelText) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildUploadButton(String label, VoidCallback onTap, String? fileName,
      {bool isFullWidth = false}) {
    return Expanded(
      flex: isFullWidth ? 1 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName ?? 'Choose file',
                      style: TextStyle(
                        color: fileName != null ? Colors.black : Colors.grey.shade700,
                        overflow: TextOverflow.ellipsis,
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
}