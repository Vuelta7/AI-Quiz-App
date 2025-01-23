import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

Color strengthenColor(Color color, double factor) {
  int r = (color.red * factor).clamp(0, 255).toInt();
  int g = (color.green * factor).clamp(0, 255).toInt();
  int b = (color.blue * factor).clamp(0, 255).toInt();
  return Color.fromARGB(color.alpha, r, g, b);
}

String rgbToHex(Color color) {
  return '${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}

Color hexToColor(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

Widget buildFolderForm({
  required BuildContext context,
  required bool isLoading,
  required bool isFormValid,
  required TextEditingController folderNameController,
  required TextEditingController descriptionController,
  required Color selectedColor,
  required Function(Color) onColorChanged,
  required Function() onSave,
  required Function() onDelete,
  bool isImported = false,
  TextEditingController? folderIdController,
  Function()? onImport,
  bool isAddScreen = false,
  void Function(String)? onFieldSubmitted, // Add onFieldSubmitted parameter
  FocusNode? descriptionFocusNode, // Add FocusNode parameter
}) {
  return Column(
    children: [
      const SizedBox(height: 10),
      if (!isImported) ...[
        TextFormField(
          controller: folderNameController,
          decoration: const InputDecoration(
            hintText: 'Folder Name',
          ),
          onChanged: (value) {
            // Handle form validation state change
          },
          onFieldSubmitted:
              onFieldSubmitted, // Use the onFieldSubmitted parameter
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            hintText: 'Description',
          ),
          maxLines: 3,
          onChanged: (value) {
            // Handle form validation state change
          },
          focusNode: descriptionFocusNode, // Use the FocusNode parameter
        ),
        const SizedBox(height: 10),
        ColorPicker(
          pickersEnabled: const {
            ColorPickerType.wheel: true,
          },
          color: selectedColor,
          onColorChanged: onColorChanged,
          heading: const Text('Select color'),
          subheading: const Text('Select a different shade'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isLoading || !isFormValid ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid ? Colors.black : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            isAddScreen ? 'SUBMIT' : 'Save Changes',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        if (!isAddScreen) ...[
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isLoading || !isFormValid ? null : onDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid ? Colors.red : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Delete Folder',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ] else ...[
        const Text(
          'This folder is imported. Only the creator can edit this folder.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isLoading ? null : onImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Remove Folder',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    ],
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'PressStart2P',
        ),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
