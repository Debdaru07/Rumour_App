import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String senderName;
  final String text;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.senderName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? AppColors.accent : const Color(0xFF182028);
    final txtColor = isMe ? Colors.black : Colors.white;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            senderName,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: bg, borderRadius: radius),
            child: Text(text, style: GoogleFonts.inter(color: txtColor)),
          ),
        ],
      ),
    );
  }
}
