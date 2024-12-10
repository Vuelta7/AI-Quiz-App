import 'package:flutter/material.dart';

class DrawerContent extends StatelessWidget {
  const DrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Information About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInfoContainer(
                title: "Feedback and Question",
                content:
                    "For inquiries, suggestions, or technical issues, please email us at learnnbyitmawd12b@gmail.com. We value your input and continuously work to improve your experience.",
              ),
              const SizedBox(height: 20),
              _buildInfoContainer(
                title: "Privacy Policy",
                content: """
Ethical Considerations  
In our Learn-N application, we prioritized ethical practices to protect our participants and ensure their privacy. 

- We implemented robust security measures using encapsulation techniques to encrypt user data and prevent unauthorized access.  
- The application includes a simple login system, securely storing quiz-related data only. No personal data is collected beyond this purpose.  
- To respect anonymity, we designed the app to store only quiz-related content, ensuring the data remains untraceable to specific individuals.  
- We obtained informed consent from classmates after thoroughly explaining the study's purpose, how the app works, and how their data is securely handled. 
                """,
              ),
              const SizedBox(height: 20),
              _buildInfoContainer(
                title: "About Us",
                content:
                    "Learn-N is dedicated to enhancing learning experiences through interactive and personalized study tools. Our team works hard to provide the best learning platform with user-friendly features and innovative educational methods.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
