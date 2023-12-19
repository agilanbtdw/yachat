import 'package:flutter/material.dart';
import 'package:my_chat_app/models/profile.dart';
import 'package:my_chat_app/utils/constants.dart';
import 'package:my_chat_app/utils/route_utils.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const UserListPage(),
    );
  }
}

class _UserListPageState extends State<UserListPage> {
  late final Stream<List<Profile>> _profileStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YAChat Users'),
        actions: [
          IconButton(
              onPressed: () async {
                await _signOut();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<List<Profile>>(
        stream: _profileStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profiles = snapshot.data!;
            return profiles.isEmpty
                ? const Center(
                    child: Text('No users available to chat'),
                  )
                : ListView.builder(
                    itemCount: profiles.length * 2 - 1,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        // If the index is odd, return a Divider
                        return const Divider();
                      }
                      final itemIndex = index ~/ 2;
                      final profile = profiles[itemIndex];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(profile.username.substring(0, 2)),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          title: Text(profile.username),
                          onTap: () {
                            moveToChatPage(profile, context);
                          },
                        ),
                      );
                    },
                  );
          } else {
            return preloader;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser!.id;
    _profileStream = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps
            .map((map) => Profile.fromMap(map: map, myUserId: myUserId))
            .where((profile) => !profile.isMine)
            .toList());
    super.initState();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    moveUntilToLoginPage(context);
  }
}
