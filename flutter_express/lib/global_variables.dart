class GlobalVariables {
  static int currentIndex = 0;
}

class UserSession {
  static Map<String, dynamic>? user;
  static void setUser(Map<String, dynamic> userData) {
    user = userData;
  }

  static void clear() {
    user = null;
  }
}
