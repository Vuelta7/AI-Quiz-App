import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/provider/user_provider.dart';
import 'package:learn_n/core/widgets/learnn_text.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/features/home/activity/provider/activity_provider.dart';
import 'package:learn_n/features/home/activity/widget/folder_model.dart';
import 'package:learn_n/features/home/activity/widget/liquid_wipe_streak.dart';
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

  //TODO enhance the design of the page make the info button good
  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);
    final userId = ref.watch(userIdProvider);
    final petNameAsync = ref.watch(petNameProvider);
    final streakPointsAsync = ref.watch(streakPointsProvider);
    final textIconColor = ref.watch(textIconColorProvider);

    return Scaffold(
      backgroundColor: getShade(userColor, 300),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            streakPointsAsync.when(
              data: (streakPoints) => SizedBox(
                height: 330,
                child: Stack(
                  children: [
                    Lottie.asset(
                      'assets/effectbg.json',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: petNameAsync.when(
                        data: (petName) => LearnNText(
                          text: 'ཐི⋆$petName⋆ཋྀ $streakPoints',
                          fontSize: 30,
                          font: 'PressStart2P',
                          color: textIconColor,
                          backgroundColor: getShade(userColor, 900),
                        ),
                        loading: () => const Loading(),
                        error: (err, stack) =>
                            const Text('Error loading pet name'),
                      ),
                    ),
                    Lottie.asset(
                      streakPoints >= 30
                          ? 'assets/streakpet1.json'
                          : streakPoints >= 10
                              ? 'assets/streakpet2.json'
                              : 'assets/streakpet3.json',
                      width: double.infinity,
                      height: 300,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: const LiquidSwipeStreak(),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.info_rounded),
                        color: textIconColor,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Loading(),
              error: (err, stack) => const Text('Error loading streak pet'),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Weekly Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textIconColor,
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
