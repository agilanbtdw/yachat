import 'package:flutter/material.dart';
import 'package:my_chat_app/utils/constants.dart';
import 'package:my_chat_app/utils/route_utils.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (session == null) {
      moveUntilToRegisterPage(context);
    } else {
      moveUntilToUserListPage(context);
    }
  }
}
