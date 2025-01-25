import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

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
