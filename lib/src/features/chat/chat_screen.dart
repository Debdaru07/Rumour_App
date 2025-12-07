import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'chat_controller.dart';
import '../../models/message_model.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/date_separator.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String roomId = args?['roomId'];
    final String? roomCode = args?['roomCode'];
    final Map<String, dynamic> identity =
        args?['identity'] ?? {'id': 'anon', 'name': 'Anonymous', 'avatar': ''};

    return ChangeNotifierProvider(
      create: (_) {
        final c = ChatController();
        c.startListening(roomId);
        return c;
      },
      child: ChatScreenBody(
        roomId: roomId,
        roomCode: roomCode,
        identity: identity,
      ),
    );
  }
}

class ChatScreenBody extends StatefulWidget {
  final String roomId;
  final String? roomCode;
  final Map<String, dynamic> identity;
  const ChatScreenBody({
    super.key,
    required this.roomId,
    this.roomCode,
    required this.identity,
  });

  @override
  State<ChatScreenBody> createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<ChatScreenBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<ChatController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      "Room ${widget.roomCode ?? ''}",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Members: anonymous",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 50),
              ],
            ),
            const SizedBox(height: 20),

            // Messages
            Expanded(
              child:
                  ctrl.messages.isEmpty
                      ? Center(
                        child: Text(
                          "No messages yet",
                          style: GoogleFonts.inter(color: AppColors.textGrey),
                        ),
                      )
                      : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels <= 100 &&
                              !ctrl.loading &&
                              ctrl.hasMore) {
                            // load more older
                            ctrl.loadMore(widget.roomId);
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: ctrl.messages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // top space
                              return const SizedBox(height: 6);
                            }
                            final msg = ctrl.messages[index - 1];
                            // date separators: insert a separator when day changes
                            bool showDate = false;
                            if (index - 2 >= 0) {
                              final prev = ctrl.messages[index - 2];
                              if (msg.createdAt != null &&
                                  prev.createdAt != null) {
                                showDate =
                                    !isSameDay(msg.createdAt!, prev.createdAt!);
                              } else if (index - 2 < 0) {
                                showDate = true;
                              }
                            } else {
                              showDate = true;
                            }

                            return Column(
                              children: [
                                if (showDate)
                                  DateSeparator(
                                    text: formatDateLabel(msg.createdAt),
                                  ),
                                MessageBubble(
                                  isMe: msg.senderId == widget.identity['id'],
                                  senderName: msg.senderName,
                                  text: msg.text,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
            ),
            if (ctrl.loading) const LinearProgressIndicator(),
            MessageInputField(
              controller: _controller,
              onSend: () async {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                final msg = MessageModel(
                  id: '',
                  text: text,
                  senderId: widget.identity['id'],
                  senderName: widget.identity['name'],
                  senderAvatar: widget.identity['avatar'] ?? '',
                  createdAt: DateTime.now(),
                );
                await ctrl.sendMessage(widget.roomId, msg);
                _controller.clear();
                // scroll to bottom after delay
                Future.delayed(const Duration(milliseconds: 250), () {
                  _scroll.animateTo(
                    _scroll.position.maxScrollExtent + 80,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatDateLabel(DateTime? dt) {
    if (dt == null) return "";
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day)
      return "Today";
    return "${dt.day}-${dt.month}-${dt.year}";
  }
}
