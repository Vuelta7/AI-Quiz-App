import 'package:flutter/material.dart';
import 'package:learn_n/core/utils/general_utils.dart';
import 'package:learn_n/features/web/web_mobile_view.dart';
import 'package:learn_n/features/web/web_pc_view.dart';

class WebMain extends StatelessWidget {
  const WebMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isMobileWeb(context) ? const WebMobileview() : const WebPCView(),
    );
  }
}
