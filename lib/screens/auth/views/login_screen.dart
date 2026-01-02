import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await AuthService.login(email: email, password: password);

    if (!mounted) return;

    if (result['success']) {
      final userId = result['userId']?.toString();
      if (userId != null && mounted) {
        Provider.of<CartProvider>(context, listen: false).setUser(userId);
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Email ou mot de passe incorrect'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset(
              //   "assets/images/okkkk.jpg",
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              // ),
              const SizedBox(height: defaultPadding),
              Text("Welcome back!", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: defaultPadding / 2),
              const Text("Log in with your data that you entered during your registration."),
              const SizedBox(height: defaultPadding),

              // Form avec clé
              Form(
                key: _formKey,
                child: LogInForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
              ),

              const SizedBox(height: defaultPadding),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text("Log in", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: defaultPadding / 2),
              Center(
                child: Column(
                  children: [
                    const Text("Vous avez oublié votre mot de passe ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, passwordRecoveryScreenRoute);
                      },
                      child: const Text("Récupérer mot de passe"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height > 700 ? size.height * 0.1 : defaultPadding),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, signUpScreenRoute);
                      },
                      child: const Text("Sign up"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
