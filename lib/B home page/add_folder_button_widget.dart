import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/add_folder_dialog.dart';

class AddFolderButtonWidget extends StatelessWidget {
  const AddFolderButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddFolderDialog();
          },
        );
      },
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.hexagon_rounded,
            size: 80,
            color: Colors.black,
          ),
          Icon(
            Icons.add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
