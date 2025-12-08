import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String senderName;
  final String text;
  final DateTime? timestamp;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.senderName,
    required this.text,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 300), // Figma width
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ---------------- SENDER NAME (Only for others) ----------------
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  "@$senderName",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),

            // ---------------- MESSAGE BUBBLE ----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:
                    isMe ? AppColors.accent : const Color(0xFF0F1525), // navy
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
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Message Text
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isMe ? Colors.black : Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Timestamp (inside bubble bottom-right)
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
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "";
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
