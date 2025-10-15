import 'package:flutter/material.dart';
import 'package:vdrivpartner/screens/assigned.dart';
import 'package:vdrivpartner/screens/permanent_home.dart';

class FAQScreen extends StatefulWidget {
  final String selectedLanguage;
  
  const FAQScreen({Key? key, required this.selectedLanguage}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What is the process of joining?',
      'answer': 'The joining process involves several steps, including registration, document submission, and a background check. You can find more detailed information on our website.',
    },
    {
      'question': 'How much time is required to join?',
      'answer': 'The time required to join varies depending on how quickly you can complete all the required steps and submit your documents. It typically takes a few days to a couple of weeks.',
    },
    {
      'question': 'Do I need to pay anything?',
      'answer': 'No, there are no fees to join. However, you may need to purchase some essential items like T-shirts or other equipment.',
    },
    {
      'question': 'How many T-shirts can we buy?',
      'answer': 'You can purchase a maximum of three T-shirts at a time. Additional T-shirts can be purchased later as needed.',
    },
    {
      'question': 'Do you provide insurance?',
      'answer': 'Yes, we provide insurance coverage for all our members. Details about the insurance policy will be provided during the onboarding process.',
    },
    {
      'question': 'What is BGV?',
      'answer': 'BGV stands for Background Verification. This is a standard procedure to ensure the safety and security of all our members and customers.',
    },
    {
      'question': 'What is test Drive process?',
      'answer': 'The test drive process is a practical assessment to evaluate your skills. You will be guided through a series of tasks to ensure you meet our quality standards.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141414),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: ListView.separated(
                itemCount: faqs.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(
                      faqs[index]['question']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF141414),
                      ),
                    ),
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFfafafa),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            faqs[index]['answer']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600], 
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VDriverDashboard(selectedLanguage: widget.selectedLanguage,name: "Zaid",driverid: "V123",showToast: false)));
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}