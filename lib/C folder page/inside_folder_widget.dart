import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_appbar_widget.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_body_widget.dart';
import 'package:learn_n/C%20folder%20page/play_button_widget.dart';

class InsideFolderWidget extends StatelessWidget {
  const InsideFolderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: insideFolderAppBarWidget(context),
      body: const InsideFolderBodyWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const PlayButtonWidget(),
    );
  }
}
