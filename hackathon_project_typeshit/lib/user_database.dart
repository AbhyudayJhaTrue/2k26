// ---------------------------------------------------------------------------
// USER DATABASE (hackathon demo only)
// This is a hardcoded, in-memory "database" — perfect for a quick demo,
// but NOT secure for real use (passwords should never be stored in plain
// text or shipped inside app code in a real product).
// ---------------------------------------------------------------------------

class AppUser {
  final String name;
  final String password;
  final String role; // "Student", "Teacher", or "Admin"

  const AppUser({
    required this.name,
    required this.password,
    required this.role,
  });
}

const List<AppUser> kUserDatabase = [
  // ---- Students ----
  AppUser(name: "Pranav", password: "1234", role: "Student"),
  AppUser(name: "Kushagr", password: "1234", role: "Student"),
  AppUser(name: "Adhvik", password: "1234", role: "Student"),

  // ---- Teachers ----
  AppUser(name: "Jason", password: "1234", role: "Teacher"),
  AppUser(name: "Jack", password: "1234", role: "Teacher"),

  // ---- Admin ----
  AppUser(name: "Abhyuday", password: "1234", role: "Admin"),
];

/// Checks name + password + role against the database.
/// Returns the matching AppUser if valid, otherwise null.
AppUser? validateLogin({
  required String name,
  required String password,
  required String role,
}) {
  for (final user in kUserDatabase) {
    if (user.name.trim().toLowerCase() == name.trim().toLowerCase() &&
        user.password == password &&
        user.role == role) {
      return user;
    }
  }
  return null;
}