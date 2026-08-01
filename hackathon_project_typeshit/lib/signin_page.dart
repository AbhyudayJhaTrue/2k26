import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'user_database.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/teacher_admin_shell.dart';

// ---------------------------------------------------------------------------
// SIGN IN PAGE
// Replace "XXX" below with your actual website/project name.
// ---------------------------------------------------------------------------

const String kWebsiteName = "CampusCore";
const String kTagline = "A CODEMASTERS PROJECT";

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

  final List<String> _roles = ["Student", "Teacher"];

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
                : TeacherAdminShell(
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
              AppTheme.gradientStart,
              AppTheme.gradientMiddle,
              AppTheme.gradientEnd,
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
                  // ---- Hero card ----
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.school_rounded, size: 32, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          kWebsiteName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          kTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: const [
                            _FeatureChip(icon: Icons.person, label: 'Student friendly'),
                            _FeatureChip(icon: Icons.laptop_mac, label: 'Teacher access'),
                            _FeatureChip(icon: Icons.map, label: 'Campus map'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- Sign-in card ----
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.cardShadow,
                      border: Border.all(color: Colors.black.withValues(alpha: .05)),
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
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Sign in to continue",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name field
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppTheme.ink),
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
                            style: const TextStyle(color: AppTheme.ink),
                            decoration: _inputDecoration(
                              label: "Password",
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.primary,
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
                            value: _selectedRole,
                            dropdownColor: AppTheme.card,
                            decoration: _inputDecoration(
                              label: "Role",
                              icon: Icons.badge_outlined,
                            ),
                            style: const TextStyle(color: AppTheme.ink),
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
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              'Need help signing in? Ask your teacher for your credentials.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black.withValues(alpha: .55), fontSize: 12),
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
      labelStyle: const TextStyle(color: AppTheme.muted),
      prefixIcon: Icon(icon, color: AppTheme.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(.94),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.card.withOpacity(.18)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: .08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
