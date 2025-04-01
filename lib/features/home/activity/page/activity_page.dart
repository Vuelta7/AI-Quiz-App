import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/utils/user_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/features/home/activity/provider/activity_provider.dart';
import 'package:learn_n/features/home/activity/widget/folder_model.dart';
import 'package:learn_n/features/home/activity/widget/shop.dart';
import 'package:lottie/lottie.dart';

class ActivtyPage extends ConsumerStatefulWidget {
  const ActivtyPage({super.key});

  @override
  _ActivtyPageState createState() => _ActivtyPageState();
}

class _ActivtyPageState extends ConsumerState<ActivtyPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  //TODO make conditions and info how to update streakpet
  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);
    final userId = ref.watch(userIdProvider);
    final petNameAsync = ref.watch(petNameProvider);
    return Scaffold(
      backgroundColor: getShade(userColor, 300),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Lottie.asset(
                  'assets/effectbg.json',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
                Lottie.asset(
                  'assets/streakpet3.json',
                  width: double.infinity,
                  height: 300,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: petNameAsync.when(
                data: (petName) => Text(
                  petName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                loading: () => const Loading(),
                error: (err, stack) => const Text('Error loading pet name'),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
              decoration: BoxDecoration(
                color: getShade(userColor, 600),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Weekly Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FolderModel(
                    folderId: '4612',
                    folderName: 'Programming Fundamentals',
                    description:
                        'This Folder helps you to learn the basics of programming terms.',
                    isImported: true,
                    headerColor: getShade(userColor, 900),
                    userId: userId!,
                    isActivity: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FolderModel(
                    folderId: '4612',
                    folderName: 'SQL Fundamentals',
                    description:
                        'This Folder helps you to learn the basics of Database terms.',
                    isImported: true,
                    headerColor: getShade(userColor, 900),
                    userId: userId,
                    isActivity: true,
                  ),
                  const Shop(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
