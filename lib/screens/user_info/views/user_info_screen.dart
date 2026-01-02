import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/components/network_image_with_loader.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _avatarPreview = 'https://i.imgur.com/IXnwbLk.png';
  bool _loading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final base64Str = base64Encode(bytes);
      // On utilise un data URI générique en PNG, suffisant pour l'affichage
      final dataUri = 'data:image/png;base64,$base64Str';

      if (!mounted) return;
      setState(() {
        _avatarPreview = dataUri;
      });
    } catch (_) {
      // En cas d'erreur, on ne modifie pas l'avatar
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _loading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return;
      }

      final res = await http.get(
        Uri.parse('http://localhost:3000/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final username = (data['username'] ?? '').toString();
        final email = (data['email'] ?? '').toString();
        final avatar = (data['avatarUrl'] ?? '').toString();
        final address = (data['address'] ?? '').toString();
        final city = (data['city'] ?? '').toString();

        _usernameController.text = username;
        _emailController.text = email;
        _addressController.text = address;
        _cityController.text = city;

        if (mounted) {
          setState(() {
            _avatarPreview = avatar.isNotEmpty
                ? avatar
                : 'https://i.imgur.com/IXnwbLk.png';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return;
      }

      final body = <String, dynamic>{
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'avatarUrl': _avatarPreview,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
      };

      final res = await http.patch(
        Uri.parse('http://localhost:3000/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final updatedUsername = (data['username'] ?? '').toString();
        await AuthService.setUsername(updatedUsername);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour du profil')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: NetworkImageWithLoader(
                              _avatarPreview,
                              radius: 40,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickAvatar,
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
