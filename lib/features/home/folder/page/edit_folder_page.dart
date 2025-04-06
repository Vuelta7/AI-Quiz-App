import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/custom_appbar.dart';
import 'package:learn_n/core/widgets/folder_form.dart';
import 'package:learn_n/features/home/folder/provider/folder_provider.dart';

class EditFolderPage extends ConsumerStatefulWidget {
  final String folderId;
  final String initialFolderName;
  final String initialDescription;
  final Color initialColor;
  final bool isImported;

  const EditFolderPage({
    super.key,
    required this.folderId,
    required this.initialFolderName,
    required this.initialDescription,
    required this.initialColor,
    this.isImported = false,
  });

  @override
  ConsumerState<EditFolderPage> createState() => _EditFolderPageState();
}

class _EditFolderPageState extends ConsumerState<EditFolderPage> {
  late TextEditingController folderNameController;
  late TextEditingController descriptionController;
  late Color _selectedColor;
  final FocusNode descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    folderNameController =
        TextEditingController(text: widget.initialFolderName);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    folderNameController.dispose();
    descriptionController.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return folderNameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(folderControllerProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Folder',
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: getColorForTextAndIcon(_selectedColor),
          ),
        ),
        color: _selectedColor,
      ),
      backgroundColor: _selectedColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: buildFolderForm(
            context: context,
            isLoading: isLoading,
            isFormValid: _isFormValid,
            folderNameController: folderNameController,
            descriptionController: descriptionController,
            selectedColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            onSave: () async {
              if (!_isFormValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields.'),
                  ),
                );
                return;
              }

              await ref.read(folderControllerProvider.notifier).editFolder(
                    folderId: widget.folderId,
                    folderName: folderNameController.text.trim(),
                    description: descriptionController.text.trim(),
                    color: rgbToHex(_selectedColor),
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Folder updated successfully!')),
              );
              Navigator.pop(context);
            },
            isImported: widget.isImported,
            onImport: () async {
              await ref
                  .read(folderControllerProvider.notifier)
                  .removeFolderFromHome(folderId: widget.folderId);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Folder removed successfully!')),
              );
              Navigator.pop(context);
            },
            isAddScreen: false,
            folderIdController: null,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(descriptionFocusNode);
            },
            descriptionFocusNode: descriptionFocusNode,
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}
