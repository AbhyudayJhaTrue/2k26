import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'user_database.dart';
import 'home_screen.dart';
import 'screens/student/student_dashboard.dart';

// ---------------------------------------------------------------------------
// SIGN IN PAGE
// Replace "XXX" below with your actual website/project name.
// ---------------------------------------------------------------------------

const String kWebsiteName = "SafeSpace";
const String kTagline = "Dashing campus collaboration for every student";

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  bool _obscurePassword = true;

  final List<String> _roles = ["Student", "Teacher", "Admin"];

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      final user = validateLogin(
        name: _nameController.text,
        password: _passwordController.text,
        role: _selectedRole!,
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign in successful ✅"),
            backgroundColor: Color(0xFF00B894), // green
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => user.role == 'Student'
                ? StudentDashboard(studentName: user.name)
                : HomeScreen(
                    name: user.name,
                    role: user.role,
                  ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Incorrect name, password, or role ❌"),
            backgroundColor: Color(0xFFD63031), // red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.primary,
              AppTheme.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ---- Title + tagline ----
                  Text(
                    kWebsiteName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: .8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ---- Sign-in card ----
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.card.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: Colors.white.withValues(alpha: .12)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1147),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Sign in to continue",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              label: "Name",
                              icon: Icons.person_outline,
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? "Please enter your name"
                                : null,
                          ),
                          const SizedBox(height: 18),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              label: "Password",
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF6C5CE7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? "Please enter your password"
                                : null,
                          ),
                          const SizedBox(height: 18),

                          // Role dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: _inputDecoration(
                              label: "Role",
                              icon: Icons.badge_outlined,
                            ),
                            items: _roles
                                .map((role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? "Please select a role" : null,
                          ),
                          const SizedBox(height: 28),

                          // Sign in button
                          HoverScale(
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                  shadowColor: AppTheme.primary.withValues(alpha: .4),
                                ),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.card.withValues(alpha: .08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}