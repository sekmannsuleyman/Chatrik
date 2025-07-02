import 'package:flutter/material.dart';
import 'package:tasarim_calismasi4/main_screen/private_group_screen.dart';
import 'package:tasarim_calismasi4/main_screen/public_group_screen.dart';
import '../constants.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: Constants.private.toUpperCase()),
              Tab(text: Constants.public.toUpperCase()),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrivateGroupScreen(),
            PublicGroupScreen(),
          ],
        ),
      ),
    );
  }
}