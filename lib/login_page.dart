import 'package:flutter/material.dart';
import 'package:gdapp/services/auth_service.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/student/dashboard_page.dart';
import 'package:gdapp/supervisor/supervisor_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

<<<<<<< HEAD
  String _normalizeRole(String? rawRole) {
    if (rawRole == null) return '';
    final value = rawRole.trim().toUpperCase();
    if (value.contains('SUPERVISOR')) return 'SUPERVISOR';
    if (value.contains('STUDENT')) return 'STUDENT';
    return value;
  }

=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  Future<void> _handleSignIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.login(username, password);
<<<<<<< HEAD

      final token = response['token']?.toString();
      final userRole = response['role']?.toString();
      final normalizedRole = _normalizeRole(userRole);

      debugPrint('Extracted role: $userRole -> $normalizedRole');

      if (normalizedRole.isEmpty) {
        debugPrint('Error: Role extraction failed for response: $response');
        throw Exception(
            'Unable to determine user role from server response. Please contact support.');
      }

      if (token != null) {
        final preview = token.length > 5 ? token.substring(0, 5) : token;
        debugPrint('Token extracted successfully: $preview...');
        ApiService.authToken = token;
      } else {
        debugPrint(
            'Warning: Login successful but no token found in response keys: ${response.keys.toList()}');
=======
      
      // Extract token from response (handle standard formats)
      debugPrint('Login Response Keys: ${response.keys.toList()}');
      final token = response['token'] ?? response['accessToken'] ?? response['data']?['token'];
      
      // Extract user role from response (handle various formats)
      String? userRole;
      if (response['role'] != null) {
        userRole = response['role'].toString();
      } else if (response['user']?['role'] != null) {
        userRole = response['user']['role'].toString();
      } else if (response['data']?['role'] != null) {
        userRole = response['data']['role'].toString();
      } else if (response['data']?['user']?['role'] != null) {
        userRole = response['data']['user']['role'].toString();
      }
      
      debugPrint('Extracted role: $userRole');
      
      // Validate that the user has a supported role
      if (userRole == null) {
        throw Exception('Unable to determine user role. Please contact support.');
      }
      
      final roleUpper = userRole.toUpperCase();
      
      if (token != null) {
        debugPrint('Token extracted successfully');
        ApiService.authToken = token.toString();
      } else {
        debugPrint('Warning: Login successful but no token found in response');
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      }

      if (mounted) {
        Widget destination;
<<<<<<< HEAD
        if (normalizedRole == 'SUPERVISOR') {
          destination = const SupervisorShell();
        } else if (normalizedRole == 'STUDENT') {
          destination = const DashboardPage();
        } else {
          throw Exception(
              'Your role ($userRole) is not supported in this app.');
        }

=======
        if (roleUpper == 'SUPERVISOR') {
          destination = const SupervisorShell();
        } else if (roleUpper == 'STUDENT') {
          destination = const DashboardPage();
        } else {
          throw Exception('Your role ($userRole) is not supported in this app.');
        }
        
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destination),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else {
        if (mounted) {
          String message = "Google Sign-In failed or canceled";
          // Check if Firebase is not initialized to give better error message
          // Note: In a real app we'd check the flag from main.dart
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              action: SnackBarAction(
                label: "Why?",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Configuration Required"),
                      content: const Text(
<<<<<<< HEAD
                          "Google Sign-In requires Firebase configuration files (google-services.json for Android, GoogleService-Info.plist for iOS).\n\n"
                          "Please follow the implementation walkthrough for setup instructions."),
=======
                        "Google Sign-In requires Firebase configuration files (google-services.json for Android, GoogleService-Info.plist for iOS).\n\n"
                        "Please follow the implementation walkthrough for setup instructions."
                      ),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Blue Background Header
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2169E1), // Primary Blue
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.school_outlined, // Graduation Cap Icon
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back, please sign in',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Sign In Form Card
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
<<<<<<< HEAD
                          enabled: !_isLoading,
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                          decoration: InputDecoration(
                            hintText: 'Enter username',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF3F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
<<<<<<< HEAD
                          enabled: !_isLoading,
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF3F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2169E1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
<<<<<<< HEAD
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
=======
                            child: _isLoading && _usernameController.text.isNotEmpty
                                ? const CircularProgressIndicator(color: Colors.white)
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
<<<<<<< HEAD
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
=======
                              padding: const EdgeInsets.symmetric(horizontal: 16),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                              child: Text(
                                'Or sign in with',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1024px-Google_\"G\"_logo.svg.png',
                                        height: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Google',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF2169E1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
