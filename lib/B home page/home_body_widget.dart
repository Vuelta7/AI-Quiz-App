import 'package:flutter/material.dart';
import 'package:learn_n/model%20widgets/folder_model_widget.dart';

class HomeBodyWidget extends StatelessWidget {
  const HomeBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            FolderModelWidget(title: "Python"),
          ],
        ),
      ),
    );
  }
}
