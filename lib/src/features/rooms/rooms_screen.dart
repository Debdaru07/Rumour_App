import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController codeCtrl = TextEditingController();

  bool creating = false;
  String? errorText;

  Future<void> _createRoom() async {
    final name = nameCtrl.text.trim();
    final code = codeCtrl.text.trim();

    if (name.isEmpty || code.isEmpty) {
      setState(() => errorText = "Both fields are required.");
      return;
    }

    if (code.length != 4) {
      setState(() => errorText = "Room code must be 4 digits.");
      return;
    }

    setState(() {
      creating = true;
      errorText = null;
    });

    final query =
        await FirebaseFirestore.instance
            .collection("rooms")
            .where("code", isEqualTo: code)
            .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        creating = false;
        errorText = "Room code already exists. Choose another.";
      });
      return;
    }

    final newRoom = await FirebaseFirestore.instance.collection("rooms").add({
      "name": name,
      "code": code,
      "members": [],
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      "/name",
      arguments: {"roomId": newRoom.id, "roomCode": code},
    );

    setState(() => creating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            Center(
              child: Text(
                "Create a Room",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Existing Rooms",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 14),

                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("rooms")
                              .orderBy("createdAt", descending: true)
                              .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }

                        final docs = snap.data!.docs;

                        if (docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "No rooms available.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children:
                              docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final roomId = doc.id;
                                final roomName = data["name"] ?? '';
                                final roomCode = data["code"] ?? '';
                                final members = data["members"] ?? [];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/name",
                                      arguments: {
                                        "roomId": roomId,
                                        "roomCode": roomCode,
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F1525),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.group,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              roomName,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              "${members.length} members",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: AppColors.textGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Create a New Room",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _inputField(
                      controller: nameCtrl,
                      label: "Room Name",
                      hint: "e.g. Weekend Sync",
                    ),

                    const SizedBox(height: 20),

                    _inputField(
                      controller: codeCtrl,
                      label: "Room Code",
                      hint: "Enter a 4-digit code",
                      keyboard: TextInputType.number,
                    ),

                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    const SizedBox(height: 26),

                    GestureDetector(
                      onTap: creating ? null : _createRoom,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child:
                              creating
                                  ? const CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  )
                                  : Text(
                                    "Create & Join Room",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/join"),
                        child: Text(
                          "Join a Room?",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
