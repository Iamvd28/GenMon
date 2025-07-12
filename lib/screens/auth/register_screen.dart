import 'package:flutter/material.dart';
import '../../styles/auth_styles.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/animated_background.dart';
import '../../widgets/auth/social_icons.dart';
import '../home/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 2)); // Simulated delay
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: AuthStyles.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Register', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF9B30FF)),
          Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.9),
                    blurRadius: 35,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: GoogleFonts.quicksand(
                      color: const Color(0xFF00FF00),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _InputBox(
                          controller: _nameController,
                          label: 'Full Name',
                          obscureText: false,
                          validator: _validateName,
                        ),
                        const SizedBox(height: 25),
                        _InputBox(
                          controller: _emailController,
                          label: 'Email',
                          obscureText: false,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 25),
                        _InputBox(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 25),
                        _InputBox(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              textStyle: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text('Sign Up'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Already have an account? Sign In',
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFF00FF00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 32,
            child: Text(
              'MADE BY- VAIBHAV DUBEY',
              style: GoogleFonts.quicksand(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBox extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputBox({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<_InputBox> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (focus) => setState(() => _hasFocus = focus),
        child: Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF222222),
                contentPadding: const EdgeInsets.fromLTRB(10, 25, 10, 7.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: widget.suffixIcon,
              ),
              validator: widget.validator,
            ),
            if (!_hasFocus && widget.controller.text.isEmpty)
              Positioned(
                left: 18,
                top: 18,
                child: IgnorePointer(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: GoogleFonts.quicksand(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(widget.label),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedGridBackground extends StatefulWidget {
  final double animationValue;
  const _AnimatedGridBackground({required this.animationValue});

  @override
  State<_AnimatedGridBackground> createState() => _AnimatedGridBackgroundState();
}

class _AnimatedGridBackgroundState extends State<_AnimatedGridBackground> {
  late List<List<bool>> _hovered;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initGrid();
  }

  void _initGrid() {
    final size = MediaQuery.of(context).size;
    final gridSize = size.width > 900 ? 16 : size.width > 600 ? 10 : 5;
    final rows = (size.height / (size.width / gridSize)).ceil();
    _hovered = List.generate(rows, (_) => List.generate(gridSize, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gridSize = size.width > 900 ? 16 : size.width > 600 ? 10 : 5;
    final spanSize = size.width / gridSize;
    final rows = (size.height / spanSize).ceil();
    final cols = gridSize;
    // Ensure _hovered is correct size
    if (_hovered.length != rows || _hovered[0].length != cols) {
      _hovered = List.generate(rows, (_) => List.generate(cols, (_) => false));
    }
    return SizedBox.expand(
      child: Stack(
        children: [
          // Animated background gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Color.lerp(Colors.black, const Color(0xFF00FF00), 0.15 + 0.15 * (widget.animationValue))!,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          // Grid of blocks
          ...[
            for (int y = 0; y < rows; y++)
              for (int x = 0; x < cols; x++)
                Positioned(
                  left: x * spanSize,
                  top: y * spanSize,
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() => _hovered[y][x] = true);
                    },
                    onExit: (_) {
                      setState(() => _hovered[y][x] = false);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: spanSize - 2,
                      height: spanSize - 2,
                      decoration: BoxDecoration(
                        color: _hovered[y][x] ? const Color(0xFF00FF00) : const Color(0xFF181818),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
          ],
          // Neon animated overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      const Color(0xFF00FF00).withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 