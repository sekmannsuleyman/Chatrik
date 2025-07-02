import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/all_users_list.dart';
import '../widgets/search_bar_widget.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          final searchQuery = searchProvider.searchQuery;
          return SafeArea(
            child: Column(
              children: [
                // Search bar
                SearchBarWidget(
                  onChanged: (value) {
                    searchProvider.setSearchQuery(value);
                  },
                ),

                // list of users
                Expanded(
                  child: searchQuery.isEmpty
                      ? const Center(
                          child: Text(
                            'Kişileri ara',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : AllUsersList(
                          userID: currentUser.uid,
                          searchQuery: searchQuery,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
