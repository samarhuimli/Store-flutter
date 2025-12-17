import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class LogInForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LogInForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "Email address",
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Email obligatoire";
            return null;
          },
        ),
        const SizedBox(height: defaultPadding),
        TextFormField(
          controller: widget.passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Password",
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Mot de passe obligatoire";
            return null;
          },
        ),
      ],
    );
  }
}
