import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:monthly_expense_flutter_project/core/utils/profile_image_helper.dart';
import '../../auth/data/auth_repository.dart';
import '../../providers/theme_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  String? _pickedImageData;
  XFile? _webPickedFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    _nameController.text = user?.displayName ?? "";

    final savedData = await ProfileImageHelper.getImagePath();
    if (mounted) {
      setState(() {
        _pickedImageData = savedData;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            _webPickedFile = pickedFile;
            _pickedImageData = pickedFile.path;
          } else {
            _pickedImageData = pickedFile.path;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
      }

      if (kIsWeb) {
        if (_webPickedFile != null) {
          final bytes = await _webPickedFile!.readAsBytes();
          final base64String = base64Encode(bytes);
          await ProfileImageHelper.saveImagePath(base64String);
        }
      } else {
        if (_pickedImageData != null && !_pickedImageData!.startsWith("http")) {
          final File tempFile = File(_pickedImageData!);
          if (await tempFile.exists()) {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = p.basename(_pickedImageData!);
            final savedImage = await tempFile.copy('${appDir.path}/$fileName');
            await ProfileImageHelper.saveImagePath(savedImage.path);
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ImageProvider? _getImageProvider() {
    if (_pickedImageData == null) return null;

    if (kIsWeb) {
      if (_webPickedFile != null) {
        return NetworkImage(_webPickedFile!.path);
      }
      try {
        return MemoryImage(base64Decode(_pickedImageData!));
      } catch (e) {
        return null;
      }
    } else {
      return FileImage(File(_pickedImageData!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final textColor = isDark ? Colors.white : Colors.black87;

    // 1. Get the provider first
    final imageProvider = _getImageProvider();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.teal.shade100,
                    // 2. Pass the provider here
                    backgroundImage: imageProvider,
                    // 3. CRITICAL FIX: Only enable error listener if provider is NOT null
                    onBackgroundImageError: imageProvider != null
                        ? (_, __) {
                      setState(() {
                        _pickedImageData = null;
                        _webPickedFile = null;
                      });
                    }
                        : null,
                    child: _pickedImageData == null
                        ? const Icon(Icons.person, size: 60, color: Colors.teal)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey[700]),
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: ref.read(authRepositoryProvider).currentUser?.email),
              readOnly: true,
              style: TextStyle(color: textColor.withOpacity(0.6)),
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey[700]),
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}