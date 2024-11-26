import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/add_folder_button_widget.dart';
import 'package:learn_n/B%20home%20page/drawer_widget.dart';
import 'package:learn_n/B%20home%20page/home_appbar_widget.dart';
import 'package:learn_n/B%20home%20page/home_body.dart';

class HomeMainWidget extends StatelessWidget {
  HomeMainWidget({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: const HomeAppbarWidget(),
      body: const HomeBody(),
      drawer: const DrawerWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const AddFolderButtonWidget(),
    );
  }
}
