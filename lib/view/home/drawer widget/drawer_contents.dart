import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/color_utils.dart';
import 'package:learn_n/view/home/drawer%20widget/dnd_page.dart';
import 'package:learn_n/view/home/drawer%20widget/themes_page.dart';
import 'package:learn_n/view/introduction/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerContent extends StatefulWidget {
  const DrawerContent({super.key, required this.color});
  final Color color;

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  void _showDialog(BuildContext context, String title) {
    String content;
    if (title == 'Privacy Policy') {
      content = '''
Welcome to Learn-N! Your privacy is important to us, and we are committed to protecting your data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.

1. Information We Collect

Our app is designed with encapsulation techniques, ensuring that only the necessary data is accessed and stored. We collect the following user-provided information:

Questions and Answers: The core functionality of our app is to allow users to create and store quiz questions and their corresponding answers. We do not collect unnecessary personal information beyond what is required for this feature.

2. How We Use Your Information

We use the collected data to:

Store and manage your quiz content locally within the app.
Enhance user experience by allowing easy retrieval and organization of quiz questions.
Ensure smooth functionality and performance of the application.

3. Data Security & Encapsulation

We employ encapsulation techniques in our codebase, meaning your data remains secure and accessible only to authorized components within the app. This prevents unintended data exposure or external access.

Additionally, we do not share, sell, or transmit your information to third parties. Your data remains on your device unless you choose to back it up or export it.

4. User Control & Consent

As a user, you have full control over your stored quiz data. You can modify or delete your questions and answers at any time. Since we do not collect personal information, there is no need for account deletion requests.

5. Third-Party Services

Our app does not integrate with third-party analytics, ads, or external databases. This means your data stays within the app environment, reducing privacy risks.

6. Updates to this Policy

We may update this Privacy Policy occasionally to reflect changes in our practices or legal requirements. Any updates will be posted within the app.

7. Contact Us

If you have any questions or concerns about this Privacy Policy, feel free to reach out to us at urielvuelta@gmail.com.

By using Learn-N, you agree to this Privacy Policy. Enjoy your learning experience while we handle your data responsibly!
''';
    } else if (title == 'Feedback and Question') {
      content = '''
We value your feedback! If you have any questions, suggestions, or concerns, feel free to reach out.

Contact Us: urielvuelta@gmail.com

I am Uriel Vuelta, the creator and developer of this application. Your input helps us improve and provide the best experience possible. Thank you for your support!
''';
    } else if (title == 'About Us') {
      content = '''
About Us

We are students from STI Malolos College, specifically from section ITMAWD12B. This project was developed with a mission to simplify learning applications and eliminate unnecessary complications.

Many existing apps are difficult to navigate and filled with intrusive advertisements, making the learning experience frustrating. Our goal is to provide a minimalist and user-friendly experience, ensuring that users can focus on learning without distractions.

With this app, we strive to create an efficient and accessible platform that makes studying easier and more enjoyable. Thank you for supporting our project!
''';
    } else {
      content = 'diko pa tapos to hehe';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getShade(widget.color, 300),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: widget.color,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/logo_icon.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                const Text(
                  'Learn-N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'About Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _showDialog(context, 'About Us');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _showDialog(context, 'Privacy Policy');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.feedback,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Feedback and Question',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _showDialog(context, 'Feedback and Question');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.do_not_disturb_alt_rounded,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Focus Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DoNotDisturbPage(color: widget.color),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.color_lens,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Themes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('userID');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const LiquidSwipeIntro()),
              );
            },
          ),
        ],
      ),
    );
  }
}
