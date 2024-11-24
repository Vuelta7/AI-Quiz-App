import 'package:flutter/material.dart';
import 'package:learn_n/folder%20page/inside_folder_appbar_widget.dart';
import 'package:learn_n/folder%20page/inside_folder_body_widget.dart';
import 'package:learn_n/folder%20page/play_button_widget.dart';

class InsideFolderMainWidget extends StatelessWidget {
  const InsideFolderMainWidget({super.key});

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
