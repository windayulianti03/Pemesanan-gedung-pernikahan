import 'package:flutter/material.dart';
import 'package:wedspace/services/api_service.dart';
import 'package:wedspace/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _whatsappController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String _errorMessage = '';
  
  Future<void> _saveUserInfo(int userId, String username, String whatsapp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('whatsapp', whatsapp);
    await prefs.setBool('isLoggedIn', true);
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      Map<String, dynamic> response;
      
      if (_isLogin) {
        // Login
        response = await ApiService.login(
          _usernameController.text,
          _passwordController.text,
        );
        
        if (response['error'] != null) {
          throw Exception(response['error']);
        }
        
        // Save user info
        await _saveUserInfo(
          response['user']['id'],
          response['user']['username'],
          response['user']['whatsapp'],
        );
        
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        
      } else {
        // Register
        response = await ApiService.register(
          _usernameController.text,
          _passwordController.text,
          _whatsappController.text,
        );
        
        if (response['error'] != null) {
          throw Exception(response['error']);
        }
        
        // Auto login after register
        final loginResponse = await ApiService.login(
          _usernameController.text,
          _passwordController.text,
        );
        
        if (loginResponse['error'] != null) {
          throw Exception(loginResponse['error']);
        }
        
        // Save user info
        await _saveUserInfo(
          loginResponse['user']['id'],
          loginResponse['user']['username'],
          loginResponse['user']['whatsapp'],
        );
        
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFF6A11CB),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Title with animation
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 60,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'WedSpace',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Wedding & Space Booking',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Login Card
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Color(0xFFF8F9FF),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Toggle Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedContainer(
                                            duration: Duration(milliseconds: 300),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              gradient: _isLogin ? LinearGradient(
                                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                              ) : null,
                                              color: _isLogin ? null : Colors.transparent,
                                            ),
                                            child: TextButton(
                                              onPressed: () => setState(() {
                                                _isLogin = true;
                                                _errorMessage = '';
                                              }),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                'LOGIN',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: _isLogin ? Colors.white : Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: AnimatedContainer(
                                            duration: Duration(milliseconds: 300),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              gradient: !_isLogin ? LinearGradient(
                                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                              ) : null,
                                              color: !_isLogin ? null : Colors.transparent,
                                            ),
                                            child: TextButton(
                                              onPressed: () => setState(() {
                                                _isLogin = false;
                                                _errorMessage = '';
                                              }),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                'REGISTER',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: !_isLogin ? Colors.white : Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 32),
                                  
                                  // Error Message
                                  if (_errorMessage.isNotEmpty)
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child: Container(
                                        key: ValueKey(_errorMessage),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline_rounded, 
                                                color: Colors.red[700]),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _errorMessage,
                                                style: TextStyle(
                                                  color: Colors.red[700],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  
                                  SizedBox(height: _errorMessage.isNotEmpty ? 24 : 0),
                                  
                                  // Form
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Username Field
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.1),
                                                blurRadius: 20,
                                                spreadRadius: 0,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _usernameController,
                                            decoration: InputDecoration(
                                              labelText: 'Username',
                                              labelStyle: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              prefixIcon: Container(
                                                margin: EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[200]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  color: Color(0xFF6A11CB),
                                                  size: 24,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[200]!,
                                                  width: 2,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color(0xFF6A11CB),
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 18,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Username harus diisi';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        
                                        SizedBox(height: 20),
                                        
                                        // Password Field
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.1),
                                                blurRadius: 20,
                                                spreadRadius: 0,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              labelStyle: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              prefixIcon: Container(
                                                margin: EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[200]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.lock_rounded,
                                                  color: Color(0xFF6A11CB),
                                                  size: 24,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[200]!,
                                                  width: 2,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color(0xFF6A11CB),
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 18,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Password harus diisi';
                                              }
                                              if (value.length < 6) {
                                                return 'Password minimal 6 karakter';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        
                                        SizedBox(height: 20),
                                        
                                        // WhatsApp Field (only for register)
                                        AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                          child: !_isLogin
                                              ? Container(
                                                  key: ValueKey('whatsapp_field'),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.blue.withOpacity(0.1),
                                                        blurRadius: 20,
                                                        spreadRadius: 0,
                                                        offset: Offset(0, 5),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextFormField(
                                                    controller: _whatsappController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Nomor WhatsApp',
                                                      labelStyle: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      prefixIcon: Container(
                                                        margin: EdgeInsets.only(right: 12),
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right: BorderSide(
                                                              color: Colors.grey[200]!,
                                                              width: 2,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.phone_rounded,
                                                          color: Color(0xFF6A11CB),
                                                          size: 24,
                                                        ),
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                        borderSide: BorderSide(
                                                          color: Colors.grey[200]!,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFF6A11CB),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      contentPadding: EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 18,
                                                      ),
                                                    ),
                                                    keyboardType: TextInputType.phone,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    validator: (value) {
                                                      if (!_isLogin) {
                                                        if (value == null || value.isEmpty) {
                                                          return 'Nomor WhatsApp harus diisi';
                                                        }
                                                        if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
                                                          return 'Nomor WhatsApp tidak valid';
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                )
                                              : SizedBox(key: ValueKey('empty_space'), height: 0),
                                        ),
                                        
                                        SizedBox(height: 30),
                                        
                                        // Submit Button
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF6A11CB).withOpacity(0.4),
                                                blurRadius: 20,
                                                spreadRadius: 0,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _handleSubmit,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              foregroundColor: Colors.white,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 40,
                                                vertical: 20,
                                              ),
                                              minimumSize: Size(double.infinity, 60),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                AnimatedSwitcher(
                                                  duration: Duration(milliseconds: 300),
                                                  child: _isLoading
                                                      ? Container(
                                                          width: 24,
                                                          height: 24,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 3,
                                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                                          ),
                                                        )
                                                      : Text(
                                                          _isLogin ? 'MASUK' : 'DAFTAR',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  child: AnimatedOpacity(
                                                    duration: Duration(milliseconds: 300),
                                                    opacity: _isLoading ? 0 : 1,
                                                    child: Icon(
                                                      Icons.arrow_forward_rounded,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                                            duration: Duration(milliseconds: 1800),
                                            delay: Duration(milliseconds: 800)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Switch Mode Text
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = '';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLogin ? Icons.person_add_rounded : Icons.login_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                _isLogin
                                    ? 'Belum punya akun? Daftar disini'
                                    : 'Sudah punya akun? Login disini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
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
    );
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}