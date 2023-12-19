import 'package:flutter/widgets.dart';
import 'package:my_chat_app/models/profile.dart';
import 'package:my_chat_app/pages/chat_page.dart';
import 'package:my_chat_app/pages/login_page.dart';
import 'package:my_chat_app/pages/register_page.dart';
import 'package:my_chat_app/pages/user_list_page.dart';

moveBack(BuildContext context) {
  Navigator.of(context).pop();
}

moveToChatPage(Profile receiverProfile, BuildContext context) {
  Navigator.of(context).push(ChatPage.route(receiverProfile));
}

moveToLoginPage(BuildContext context) {
  Navigator.of(context).push(LoginPage.route());
}

moveUntilToLoginPage(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(LoginPage.route(), (route) => false);
}

moveUntilToRegisterPage(BuildContext context) {
  Navigator.of(context)
      .pushAndRemoveUntil(RegisterPage.route(), (route) => false);
}

moveUntilToUserListPage(BuildContext context) {
  Navigator.of(context)
      .pushAndRemoveUntil(UserListPage.route(), (route) => false);
}
