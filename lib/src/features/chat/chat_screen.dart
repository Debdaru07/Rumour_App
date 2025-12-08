import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/message_model.dart';
import '../../core/services/room_service.dart';
import 'chat_controller.dart';
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

  // ---------------------------------------------------------------------------
  // EXIT ROOM LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _exitRoom() async {
    await RoomService().exitRoom(widget.roomId, widget.identity);

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('lastRoomId');
    prefs.remove('identity');

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/join', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<ChatController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ---------------------------------------------------------------------------
            // TOP BAR (with REALTIME member count)
            // ---------------------------------------------------------------------------
            StreamBuilder<int>(
              stream: RoomService().watchMemberCount(widget.roomId),
              builder: (context, snapshot) {
                final memberCount = snapshot.data ?? 0;

                return Row(
                  children: [
                    const SizedBox(width: 16),

                    // back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F2430),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Column(
                      children: [
                        Text(
                          "Room #${widget.roomCode}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$memberCount members",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // exit button
                    GestureDetector(
                      onTap: _exitRoom,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F2430),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // ---------------------------------------------------------------------------
            // MESSAGES LIST
            // ---------------------------------------------------------------------------
            Expanded(
              child:
                  ctrl.messages.isEmpty
                      ? Center(
                        child: Text(
                          "No messages yet",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                      )
                      : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels <= 100 &&
                              !ctrl.loading &&
                              ctrl.hasMore) {
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
                            if (index == 0) return const SizedBox(height: 6);

                            final msg = ctrl.messages[index - 1];
                            bool showDate = false;

                            final currTime = msg.createdAt;
                            DateTime? prevTime;

                            if (index - 2 < 0) {
                              showDate = true;
                            } else {
                              final prev = ctrl.messages[index - 2];
                              prevTime = prev.createdAt;

                              if (currTime == null || prevTime == null) {
                                showDate = true;
                              } else {
                                showDate = !isSameDay(currTime, prevTime);
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDate)
                                  Center(
                                    child: DateSeparator(
                                      text: formatDateLabel(msg.createdAt),
                                    ),
                                  ),

                                MessageBubble(
                                  isMe: msg.senderId == widget.identity['id'],
                                  senderAvatar: msg.senderAvatar,
                                  senderName: msg.senderName,
                                  text: msg.text,
                                  timestamp: msg.createdAt,
                                ),

                                const SizedBox(height: 4),
                              ],
                            );
                          },
                        ),
                      ),
            ),

            if (ctrl.loading)
              const LinearProgressIndicator(
                color: Colors.white24,
                minHeight: 2,
              ),

            // INPUT FIELD
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
                  senderAvatar: widget.identity['avatar'],
                  createdAt: DateTime.now(),
                );

                await ctrl.sendMessage(widget.roomId, msg);

                _controller.clear();

                Future.delayed(const Duration(milliseconds: 200), () {
                  _scroll.animateTo(
                    _scroll.position.maxScrollExtent + 120,
                    duration: const Duration(milliseconds: 250),
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

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatDateLabel(DateTime? dt) {
    if (dt == null) return "";
    final now = DateTime.now();
    if (isSameDay(dt, now)) return "Today";
    return "${dt.day}-${dt.month}-${dt.year}";
  }
}
