class Validators {
  static bool isValidRoomCode(String code) {
    return code.trim().length == 4; // or 6 — depending on design
  }
}
