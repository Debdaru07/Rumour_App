import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../chat/widgets/room_tile.dart';

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

    final exists =
        await FirebaseFirestore.instance
            .collection("rooms")
            .where("code", isEqualTo: code)
            .get();

    if (exists.docs.isNotEmpty) {
      setState(() {
        creating = false;
        errorText = "Room code already exists.";
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

  Future<void> _deleteRoom(String roomId) async {
    await FirebaseFirestore.instance.collection("rooms").doc(roomId).delete();
  }

  void _confirmDelete(String roomId, String roomName) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              "Delete Room?",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            content: Text(
              "Are you sure you want to delete \"$roomName\"?",
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteRoom(roomId);
                },
                child: Text(
                  "Delete",
                  style: GoogleFonts.poppins(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
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
                              padding: EdgeInsets.all(24),
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
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children:
                              docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return RoomTile(
                                  roomId: doc.id,
                                  name: data["name"] ?? "",
                                  code: data["code"] ?? "",
                                  members:
                                      (data["members"] as List? ?? []).length,

                                  onOpen: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/name",
                                      arguments: {
                                        "roomId": doc.id,
                                        "roomCode": data["code"],
                                      },
                                    );
                                  },

                                  onDelete:
                                      () => _confirmDelete(
                                        doc.id,
                                        data["name"] ?? "",
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
