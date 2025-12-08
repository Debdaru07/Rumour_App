import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime? timestamp;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    const double maxBubbleWidth = 280;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade800,
                backgroundImage:
                    senderAvatar.isNotEmpty ? NetworkImage(senderAvatar) : null,
                child:
                    senderAvatar.isEmpty
                        ? Text(
                          senderName.isNotEmpty ? senderName[0] : "?",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                        : null,
              ),
            ),

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 6),
                    child: Text(
                      "@$senderName",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),

                Container(
                  constraints: const BoxConstraints(maxWidth: maxBubbleWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.accent : const Color(0xFF0F1525),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          isMe
                              ? const Radius.circular(18)
                              : const Radius.circular(6),
                      bottomRight:
                          isMe
                              ? const Radius.circular(6)
                              : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.4,
                          color: isMe ? Colors.black : Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _formatTime(timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color:
                              isMe
                                  ? Colors.black.withOpacity(0.55)
                                  : Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "";
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
