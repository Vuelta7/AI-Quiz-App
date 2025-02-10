import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:learn_n/components/loading.dart';
import 'package:learn_n/home%20page/folder%20page/folder_model.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderPage extends StatefulWidget {
  final String userId;
  final Color color;

  const FolderPage({super.key, required this.userId, required this.color});

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _folders = [];
  String searchQuery = '';
  Map<String, int> _folderPositions = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
    _loadFolderOrder();
  }

  void _updateSearchQuery() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadFolderOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final folderOrder = prefs.getStringList('folderOrder_${widget.userId}');
    if (folderOrder != null) {
      setState(() {
        _folderPositions = {
          for (var item in folderOrder)
            item.split(':')[0]: int.parse(item.split(':')[1])
        };
      });
    }
  }

  Future<void> _saveFolderOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final folderOrder = _folderPositions.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await prefs.setStringList('folderOrder_${widget.userId}', folderOrder);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _folders.removeAt(oldIndex);
      _folders.insert(newIndex, item);

      for (int i = 0; i < _folders.length; i++) {
        _folderPositions[_folders[i].id] = i;
      }
    });
    _saveFolderOrder();
  }

  List<DocumentSnapshot> _filterFolders(List<DocumentSnapshot> docs) {
    return docs.where((folderDoc) {
      final folderData = folderDoc.data() as Map<String, dynamic>;
      final folderName = folderData['folderName'] as String;
      return folderName.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getShade(widget.color, 600),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 0),
            child: TextFormField(
              style: const TextStyle(
                fontFamily: 'Arial',
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search Folder',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                labelText: 'Search folder',
                labelStyle: const TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.white,
                ),
                filled: true,
                fillColor: getShade(widget.color, 600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('folders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                }

                _folders =
                    _filterFolders(snapshot.data!.docs.where((folderDoc) {
                  final folderData = folderDoc.data() as Map<String, dynamic>;
                  final accessUsers =
                      List<String>.from(folderData['accessUsers']);
                  return folderData['creator'] == widget.userId ||
                      accessUsers.contains(widget.userId);
                }).toList());

                _folders.sort((a, b) {
                  final aPos = _folderPositions[a.id] ?? 0;
                  final bPos = _folderPositions[b.id] ?? 0;
                  return aPos.compareTo(bPos);
                });

                if (_folders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Lottie.asset('assets/folders.json'),
                          const Text(
                            'No Folder here\nCreate one by clicking the Add Folder.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ReorderableListView.builder(
                  itemCount: _folders.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final folderDoc = _folders[index];
                    final folderData = folderDoc.data() as Map<String, dynamic>;
                    final isImported =
                        List<String>.from(folderData['accessUsers'])
                            .contains(widget.userId);

                    return ListTile(
                      key: ValueKey(folderDoc.id),
                      title: FolderModel(
                        folderId: folderDoc.id,
                        headerColor: hexToColor(folderData['color']),
                        folderName: folderData['folderName'],
                        description: folderData['description'],
                        isImported: isImported,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
