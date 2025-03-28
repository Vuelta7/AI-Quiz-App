import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/features/home/setting%20page/widget/dnd_page.dart';
import 'package:learn_n/features/home/setting%20page/widget/feedback.dart';
import 'package:learn_n/features/home/setting%20page/widget/info_page.dart';
import 'package:learn_n/features/home/setting%20page/widget/themes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userColor = ref.watch(userColorProvider);
    return Scaffold(
      backgroundColor: getShade(userColor, 300),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  color: userColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
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
                        fontSize: 16,
                        fontFamily: 'PressStart2P',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const Divider(),
                _buildTile(context, 'About Us', Icons.info, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoPage(
                        title: 'About Us',
                        description: '''
We are students from STI Malolos College, specifically from section ITMAWD12B. This project was developed with a mission to simplify learning applications and eliminate unnecessary complications.

Many existing apps are difficult to navigate and filled with intrusive advertisements, making the learning experience frustrating. Our goal is to provide a minimalist and user-friendly experience, ensuring that users can focus on learning without distractions.

With this app, we strive to create an efficient and accessible platform that makes studying easier and more enjoyable. Thank you for supporting our project!
''',
                      ),
                    ),
                  );
                }),
                _buildTile(context, 'Our Team', Icons.group, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoPage(
                        title: 'Our Team',
                        description: '''
Developer – Mark Uriel "The King" Vuelta
Leads the development and continuous improvement of the application.  

Leader – August Evangelista  
Oversees all company operations and ensures smooth business processes.  

Designer – Jhikeine Lopez  
Designs the application's interface and overall visual experience.  

Marketer – Johann Francisco  
Identifies market challenges and potential issues that could impact the company.  

Tester – Justine Adriano
Detects and addresses bugs and technical flaws by rigorously testing the application.  

Generalists – Kyle Raine & Mikko Dela Cruz  
Take on various tasks essential for the company’s operations.  
''',
                      ),
                    ),
                  );
                }),
                _buildTile(context, 'Our Purpose', Icons.lightbulb, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoPage(
                        title: 'Our Purpose',
                        description: '''
Vision  
Learn-N helps students improve their learning by making studying easier and more effective.

Mission  
Learn-N enhances learning by continuously improving based on student feedback while keeping all essential features free for everyone.

Goals  
- Simplify studying for all students.  
- Adapt to students' needs and feedback.  
- Remain free and accessible to everyone.  
- Use proven study methods like active recall and spaced repetition.  

Core Values  
- Continuous improvement.  
- Accessibility for all.  
- Efficient and effective learning.  
- Prioritizing student feedback.  
''',
                      ),
                    ),
                  );
                }),
                _buildTile(context, 'Privacy Policy', Icons.privacy_tip, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoPage(
                        title: 'Privacy Policy',
                        description: '''
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

If you have any questions or concerns about this Privacy Policy, feel free to reach out to us at LearnNCustomerServices@gmail.com.

By using Learn-N, you agree to this Privacy Policy. Enjoy your learning experience while we handle your data responsibly!
''',
                      ),
                    ),
                  );
                }),
                _buildTile(context, 'Feedback', Icons.feedback, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackPage(),
                    ),
                  );
                }),
                _buildTile(
                    context, 'Focus Mode', Icons.do_not_disturb_alt_rounded,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoNotDisturbPage(),
                    ),
                  );
                }),
                _buildTile(context, 'Themes', Icons.color_lens, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemesPage(),
                    ),
                  );
                }),
                const Divider(),
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
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('userId');
                    GoRouter.of(context).go('/intro');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}
