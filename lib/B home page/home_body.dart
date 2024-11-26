import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/model%20widgets/folder_model.dart';
import 'package:learn_n/util.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('folders')
          .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data here :<'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final folderDoc = snapshot.data!.docs[index];
            final folderData = folderDoc.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FolderModel(
                folderId: folderDoc.id,
                headerColor: hexToColor(folderData['color']),
                folderName: folderData['folderName'],
                description: folderData['description'],
              ),
            );
          },
        );
      },
    );
  }
}
