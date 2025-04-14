import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/streak_pet_provider.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/provider/user_provider.dart';
import 'package:learn_n/core/widgets/custome_tile.dart';
import 'package:learn_n/core/widgets/learnn_icon.dart';
import 'package:learn_n/core/widgets/learnn_text.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/features/home/activity/provider/activity_provider.dart';
import 'package:learn_n/features/home/activity/provider/leaderboard_provider.dart';
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
  final leaderboardKey = GlobalKey();
  final shopKey = GlobalKey();
  final weeklyLibraryKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  void scrollToWeeklyLibrary() {
    final context = weeklyLibraryKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToLeaderboard() {
    final context = leaderboardKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToShop() {
    final context = shopKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);
    final userId = ref.watch(userIdProvider);
    final petNameAsync = ref.watch(petNameProvider);
    final streakPointsAsync = ref.watch(streakPointsProvider);
    final textIconColor = ref.watch(textIconColorProvider);
    final leaderboardData = ref.watch(leaderboardProvider);
    final streakPetAsync = ref.watch(streakPetProvider);

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
                          text: 'ཐི⋆$petName⋆ཋྀ ঔঌ$streakPointsঔঌ',
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
                    streakPetAsync.when(
                      data: (pet) => Lottie.asset(
                        pet,
                        width: double.infinity,
                        height: 300,
                      ),
                      error: (error, stackTrace) => const Loading(),
                      loading: () => const Loading(),
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
                        icon: LearnNIcon(
                          icon: Icons.info_rounded,
                          color: textIconColor,
                          shadowColor: getShade(userColor, 900),
                          offset: const Offset(0, 0.3),
                          size: 40,
                        ),
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
                    child: LearnNText(
                        fontSize: 22,
                        text: 'Activity',
                        font: 'PressStart2p',
                        color: textIconColor,
                        backgroundColor: userColor),
                  ),
                  buildTile(
                    context,
                    'Weekly Library',
                    Icons.library_books,
                    () => scrollToWeeklyLibrary(),
                    textIconColor,
                  ),
                  buildTile(
                    context,
                    'Leaderboards',
                    Icons.leaderboard,
                    () => scrollToLeaderboard(),
                    textIconColor,
                  ),
                  buildTile(
                    context,
                    'Shop',
                    Icons.storefront_rounded,
                    () => scrollToShop(),
                    textIconColor,
                  ),
                  Padding(
                    key: weeklyLibraryKey,
                    padding: const EdgeInsets.all(8.0),
                    child: LearnNText(
                        fontSize: 22,
                        text: 'Weekly Library',
                        font: 'PressStart2P',
                        color: textIconColor,
                        backgroundColor: userColor),
                  ),
                  FolderModel(
                    folderId: '3258',
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
                    folderId: '7510',
                    folderName: 'SQL Fundamentals',
                    description:
                        'This Folder helps you to learn the basics of Database terms.',
                    isImported: true,
                    headerColor: getShade(userColor, 900),
                    userId: userId,
                    isActivity: true,
                  ),
                  const Divider(),
                  Padding(
                    key: leaderboardKey,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LearnNText(
                            fontSize: 22,
                            text: 'Leaderboards',
                            font: 'PressStart2P',
                            color: textIconColor,
                            backgroundColor: userColor),
                        const SizedBox(height: 16),
                        leaderboardData.when(
                          data: (data) {
                            final streakData =
                                data['streakData'] as List<UserRanking>;
                            final donationData =
                                data['donationData'] as List<UserRanking>;
                            final currentUserId =
                                data['currentUserId'] as String;
                            return Column(
                              children: [
                                Column(
                                  children: [
                                    LeaderboardWidget(
                                      title: 'Streak',
                                      rankings: streakData,
                                      currentUserId: currentUserId,
                                      valueLabel: 'days',
                                    ),
                                    const SizedBox(height: 10),
                                    LeaderboardWidget(
                                      title: 'Donation',
                                      rankings: donationData,
                                      currentUserId: currentUserId,
                                      valueLabel: '₱',
                                      valuePrefix: true,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          loading: () => const Center(child: Loading()),
                          error: (error, _) => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Could not load leaderboards. Try again later.',
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    key: shopKey,
                    padding: const EdgeInsets.all(8.0),
                    child: const Shop(),
                  ),
                  const Divider(),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
