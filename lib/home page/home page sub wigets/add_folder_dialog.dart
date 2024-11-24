import 'package:flutter/material.dart';

class AddFolderDialog extends StatelessWidget {
  const AddFolderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add New Folder",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'PressStart2P',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: 'Folder Name',
                labelStyle: const TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add folder creation logic here
                print('Folder created!');
                Navigator.pop(context); // Close dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Create",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'PressStart2P',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
