import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/widgets/retro_button.dart';

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
          style: const TextStyle(
            fontFamily: 'Arial',
            color: Colors.black,
            fontSize: 14,
          ),
          controller: folderNameController,
          cursorColor: selectedColor,
          decoration: InputDecoration(
            hintText: 'Folder Name',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedColor,
                width: 2,
              ),
            ),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
        const SizedBox(height: 10),
        TextFormField(
          style: const TextStyle(
            fontFamily: 'Arial',
            color: Colors.black,
            fontSize: 14,
          ),
          controller: descriptionController,
          cursorColor: selectedColor,
          decoration: InputDecoration(
            hintText: 'Description',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedColor,
                width: 2,
              ),
            ),
          ),
          maxLines: 3,
          onChanged: onChanged,
          focusNode: descriptionFocusNode,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ColorPicker(
            pickersEnabled: const {
              ColorPickerType.wheel: true,
            },
            color: selectedColor,
            onColorChanged: onColorChanged,
            heading: const Text('Select color'),
            subheading: const Text('Select a different shade'),
          ),
        ),
        const SizedBox(height: 10),
        buildRetroButton(
          isAddScreen ? 'SUBMIT' : 'Save Changes',
          isFormValid ? selectedColor : Colors.grey,
          isLoading || !isFormValid ? null : onSave,
        ),
      ] else ...[
        TextFormField(
          controller: folderIdController,
          cursorColor: selectedColor,
          decoration: InputDecoration(
            hintText: 'Description',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedColor,
                width: 2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        buildRetroButton(
          'IMPORT',
          isFormValid ? Colors.black : Colors.grey,
          isLoading || !isFormValid ? null : onImport,
        ),
      ],
    ],
  );
}
