import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' show AuthStateProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';
import 'package:genmon4/screens/home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthStateProvider>(context, listen: false);
        await authProvider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
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
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
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
        title: const Text('Login', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFF00FF00)),
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
                    'Sign In',
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
                          controller: _emailController,
                          label: 'Username',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username or email';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password',
                                style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              child: Text(
                                'Signup',
                                style: GoogleFonts.quicksand(color: const Color(0xFF00FF00), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
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
                                : const Text('Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
  late List<List<bool>> _hovered = [[]];

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
    if (_hovered.length != rows || (_hovered.isNotEmpty && _hovered[0].length != cols)) {
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