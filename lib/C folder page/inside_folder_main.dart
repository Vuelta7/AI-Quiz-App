import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_appbar_widget.dart';
import 'package:learn_n/C%20folder%20page/inside_folder_body.dart';
import 'package:learn_n/C%20folder%20page/play_button_widget.dart';

class InsideFolderMain extends StatelessWidget {
  final String folderId;
  const InsideFolderMain({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: insideFolderAppBarWidget(context, folderId: folderId),
      body: InsideFolderBody(folderId: folderId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const PlayButtonWidget(),
    );
  }
}
