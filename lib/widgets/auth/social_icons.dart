import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../styles/auth_styles.dart';

class SocialIcons extends StatelessWidget {
  const SocialIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIconButton(
          icon: FontAwesomeIcons.google,
          onPressed: () {
            // TODO: Implement Google sign in
          },
        ),
        const SizedBox(width: 16),
        _SocialIconButton(
          icon: FontAwesomeIcons.facebook,
          onPressed: () {
            // TODO: Implement Facebook sign in
          },
        ),
        const SizedBox(width: 16),
        _SocialIconButton(
          icon: FontAwesomeIcons.apple,
          onPressed: () {
            // TODO: Implement Apple sign in
          },
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: IconButton(
        icon: FaIcon(
          icon,
          color: AuthStyles.primaryColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
} 