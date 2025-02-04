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
  required Function(String) onChanged,
  bool isImported = false,
  TextEditingController? folderIdController,
  Function()? onImport,
  bool isAddScreen = false,
  void Function(String)? onFieldSubmitted,
  FocusNode? descriptionFocusNode,
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
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            hintText: 'Description',
          ),
          maxLines: 3,
          onChanged: onChanged,
          focusNode: descriptionFocusNode,
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
      ] else ...[
        TextFormField(
          controller: folderIdController,
          decoration: const InputDecoration(
            hintText: 'Folder ID',
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isLoading || !isFormValid ? null : onImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid ? Colors.black : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'IMPORT',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    ],
  );
}
