import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/widgets/custom_appbar.dart';
import 'package:learn_n/core/widgets/folder_form.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:learn_n/features/home/folder/provider/folder_provider.dart';

class AddFolderPage extends ConsumerStatefulWidget {
  const AddFolderPage({super.key});

  @override
  ConsumerState<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends ConsumerState<AddFolderPage> {
  final folderNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final folderIdController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isAddingFolder = true;
  final FocusNode descriptionFocusNode = FocusNode();

  bool get isFormValid {
    return folderNameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    folderNameController.dispose();
    descriptionController.dispose();
    folderIdController.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = ref.watch(folderControllerProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Folder',
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
      body: isLoading
          ? const Loading()
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAddingFolder = true;
                          });
                        },
                        child: Container(
                          color: _isAddingFolder
                              ? getShade(_selectedColor, 600)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Add',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isAddingFolder
                                  ? Colors.white
                                  : getShade(_selectedColor, 600),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PressStart2P',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAddingFolder = false;
                          });
                        },
                        child: Container(
                          color: !_isAddingFolder
                              ? getShade(_selectedColor, 600)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Import',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isAddingFolder
                                  ? Colors.white
                                  : getShade(_selectedColor, 600),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PressStart2P',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _isAddingFolder
                          ? buildFolderForm(
                              context: context,
                              isLoading: isLoading,
                              isFormValid: isFormValid,
                              folderNameController: folderNameController,
                              descriptionController: descriptionController,
                              selectedColor: _selectedColor,
                              onColorChanged: (Color color) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              onSave: () async {
                                await ref
                                    .read(folderControllerProvider.notifier)
                                    .uploadFolderToDb(
                                      folderName:
                                          folderNameController.text.trim(),
                                      description:
                                          descriptionController.text.trim(),
                                      color: rgbToHex(_selectedColor),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Folder created successfully!')));
                                Navigator.pop(context);
                              },
                              isImported: false,
                              folderIdController: folderIdController,
                              onImport: () async {},
                              isAddScreen: true,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(descriptionFocusNode);
                                setState(() {});
                              },
                              descriptionFocusNode: descriptionFocusNode,
                              onChanged: (value) {
                                setState(() {});
                              },
                            )
                          : buildFolderForm(
                              context: context,
                              isLoading: isLoading,
                              isFormValid:
                                  folderIdController.text.trim().isNotEmpty,
                              folderNameController: folderNameController,
                              descriptionController: descriptionController,
                              selectedColor: _selectedColor,
                              onColorChanged: (Color color) {},
                              onSave: () async {},
                              isImported: true,
                              folderIdController: folderIdController,
                              onImport: () async {
                                await ref
                                    .read(folderControllerProvider.notifier)
                                    .importFolder(
                                        folderIdController.text.trim());
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Folder imported successfully!')));
                                Navigator.pop(context);
                              },
                              isAddScreen: false,
                              onFieldSubmitted: (_) {},
                              descriptionFocusNode: descriptionFocusNode,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
