import 'package:flutter/material.dart';
import 'package:learn_n/folder%20page/inside_folder_widget.dart';

// this widget is used for the HomeBody

class FolderModelWidget extends StatelessWidget {
  final String title;

  const FolderModelWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const InsideFolderWidget()),
            );
          },
          child: Container(
            width: 310,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                width: 4,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 4.0,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Favorite button
                        Icon(
                          Icons.star_border_purple500_rounded,
                          size: 40,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        // Edit button
                        Icon(
                          Icons.more_horiz_rounded,
                          size: 40,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
