import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
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
          style: TextStyle(
            fontFamily: 'Arial',
            color: getColorForTextAndIcon(selectedColor),
            fontSize: 14,
          ),
          controller: folderNameController,
          cursorColor: getColorForTextAndIcon(selectedColor),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
                width: 2.0,
              ),
            ),
            hintText: 'Folder Name',
            hintStyle: TextStyle(
              color: getColorForTextAndIcon(selectedColor),
              fontFamily: 'PressStart2P',
            ),
            filled: true,
            fillColor: selectedColor,
          ),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
        const SizedBox(height: 10),
        TextFormField(
          style: TextStyle(
            fontFamily: 'Arial',
            color: getColorForTextAndIcon(selectedColor),
            fontSize: 14,
          ),
          controller: descriptionController,
          cursorColor: selectedColor,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
                width: 2.0,
              ),
            ),
            hintText: 'Description',
            hintStyle: TextStyle(
              color: getColorForTextAndIcon(selectedColor),
              fontFamily: 'PressStart2P',
            ),
            filled: true,
            fillColor: selectedColor,
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
          heading: Text(
            'Select color',
            style: TextStyle(
              color: getColorForTextAndIcon(selectedColor),
              fontFamily: 'PressStart2P',
            ),
          ),
          subheading: const Text(
            'different shade',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'PressStart2P',
            ),
          ),
        ),
        const SizedBox(height: 10),
        buildRetroButton(
          isAddScreen ? 'SUBMIT' : 'Save Changes',
          isFormValid ? getColorForTextAndIcon(selectedColor) : Colors.grey,
          isLoading || !isFormValid ? null : onSave,
          textColor: isFormValid ? selectedColor : getShade(selectedColor, 600),
        ),
      ] else ...[
        TextFormField(
          controller: folderIdController,
          cursorColor: selectedColor,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: getColorForTextAndIcon(selectedColor),
                width: 2.0,
              ),
            ),
            hintText: 'Code',
            hintStyle: TextStyle(
              color: getColorForTextAndIcon(selectedColor),
              fontFamily: 'PressStart2P',
            ),
            filled: true,
            fillColor: selectedColor,
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        buildRetroButton(
          'IMPORT',
          isFormValid ? Colors.white : Colors.grey,
          isLoading || !isFormValid ? null : onImport,
          textColor: isFormValid
              ? getColorForTextAndIcon(selectedColor)
              : getShade(selectedColor, 600),
        ),
      ],
    ],
  );
}
