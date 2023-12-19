import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_chat_app/models/message.dart';
import 'package:my_chat_app/models/profile.dart';
import 'package:my_chat_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatefulWidget {
  final Profile receiverProfile;
  final int chatConversationId;
  final String myUserId;
  const ChatPage(
      {required this.receiverProfile,
      required this.chatConversationId,
      required this.myUserId,
      Key? key})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();

  // static Route<void> route(Profile receiverProfile) {
  //   return MaterialPageRoute(
  //     builder: (context) => ChatPage(
  //       receiverProfile: receiverProfile,
  //       chatConversationId: ,
  //     ),
  //   );
  // }
}

class CreateChatRoomIfItDoesNotExist extends StatefulWidget {
  final Profile receiverProfile;
  final myUserId = supabase.auth.currentUser!.id;
  CreateChatRoomIfItDoesNotExist({required this.receiverProfile, Key? key})
      : super(key: key);

  @override
  State<CreateChatRoomIfItDoesNotExist> createState() =>
      _CreateChatRoomIfItDoesNotExistState();

  static Route<void> route(Profile receiverProfile) {
    return MaterialPageRoute(
      builder: (context) =>
          CreateChatRoomIfItDoesNotExist(receiverProfile: receiverProfile),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;

  final Profile? profile;
  const _ChatBubble({
    Key? key,
    required this.message,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        CircleAvatar(
          child: profile == null
              ? preloader
              : Text(profile!.username.substring(0, 2)),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};
  late final myUserId = widget.myUserId;
  // bool isAllowedToChat = false;
  // bool isAllowedToFollow = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text('Start your conversation now :)'),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          /// I know it's not good to include code that is not related
                          /// to rendering the widget inside build method, but for
                          /// creating an app quick and dirty, it's fine 😂
                          _loadProfileCache(message.profileId);

                          return _ChatBubble(
                            message: message,
                            profile: _profileCache[message.profileId],
                          );
                        },
                      ),
              ),
              _MessageBar(
                senderUserId: myUserId,
                chatConversationId: widget.chatConversationId,
              ),
            ],
          );
        } else {
          return preloader;
        }
      },
    );
  }

  @override
  void initState() {
    // _checkIfFollowingTheReceiver();
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', widget.chatConversationId)
        .order('created_at')
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myUserId))
            .toList());
    super.initState();
  }

  // _checkIfFollowingTheReceiver() async {
  //   final result = await supabase
  //       .from("followers")
  //       .select("is_active")
  //       .eq("sender", myUserId)
  //       .eq("receiver", widget.receiverProfile.id)
  //       .limit(1);
  //   for (var data in result) {
  //     if (data['is_active'] == true) {
  //       setState(() {
  //         isAllowedToChat = true;
  //       });
  //     } else {
  //       setState(() {
  //         isAllowedToChat = false;
  //       });
  //     }
  //   }
  // }

  // _checkIfTheReceiverCanBeFollowed() async {
  //   if (widget.receiverProfile.followableState == FollowableState.followable) {
  //     isAllowedToFollow = true;
  //   }
  // }

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = Profile.fromMap(map: data, myUserId: myUserId);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }
}

class _CreateChatRoomIfItDoesNotExistState
    extends State<CreateChatRoomIfItDoesNotExist> {
  late final int chatConversationId;
  bool isLoading = true;
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: _buildReceiverProfileDetails()),
        body: isLoading
            ? preloader
            : isError
                ? const Center(child: Text("Something went wrong..."))
                : ChatPage(
                    receiverProfile: widget.receiverProfile,
                    chatConversationId: chatConversationId,
                    myUserId: widget.myUserId,
                  ));
  }

  @override
  void initState() {
    _doesAConversationAlreadyExists().then((conversationId) {
      if (conversationId == null) {
        _insertANewConversationBetweenUsers(
                widget.myUserId, widget.receiverProfile.id)
            .then((newConversationId) {
          setState(() {
            chatConversationId = newConversationId;
            isLoading = false;
            isError = false;
          });
        }).onError((error, stackTrace) {
          print(error);
          print(stackTrace);
          setState(() {
            isLoading = false;
            isError = true;
          });
        });
      } else {
        setState(() {
          chatConversationId = conversationId;
          isLoading = false;
          isError = false;
        });
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      setState(() {
        isLoading = false;
        isError = true;
      });
    });
    super.initState();
  }

  Widget _buildReceiverProfileDetails() {
    return Row(
      children: [
        getCircleAvatarBasedOnText(widget.receiverProfile.username),
        const SizedBox(width: 10.0),
        Text(
          widget.receiverProfile.username,
        ),
      ],
    );
  }

  Future<int?> _doesAConversationAlreadyExists() async {
    final result = await supabase
        .from("chat_room")
        .select('id')
        .or('user1_id.eq.${widget.myUserId},user2_id.eq.${widget.myUserId}')
        .or('user2_id.eq.${widget.receiverProfile.id},user1_id.eq.${widget.receiverProfile.id}')
        .limit(1);
    if (result.isNotEmpty) {
      return result[0]['id'];
    }
    return null;
  }

  Future<int> _insertANewConversationBetweenUsers(
      String senderUserId, String receiverUserId) async {
    final result = await supabase.from("chat_room").insert(
        {"user1_id": senderUserId, "user2_id": receiverUserId}).select('id');
    return result[0]['id'];
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  final String senderUserId;
  final int chatConversationId;

  const _MessageBar({
    required this.senderUserId,
    required this.chatConversationId,
    Key? key,
  }) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  void _submitMessage() async {
    final text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'profile_id': widget.senderUserId,
        'content': text,
        'chat_room_id': widget.chatConversationId
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}
