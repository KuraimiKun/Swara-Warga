import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class KtpVerificationScreen extends StatefulWidget {
  const KtpVerificationScreen({super.key});

  @override
  State<KtpVerificationScreen> createState() => _KtpVerificationScreenState();
}

class _KtpVerificationScreenState extends State<KtpVerificationScreen> {
  File? _ktpImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _ktpImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadKtp() async {
    if (_ktpImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih foto KTP terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final authService = context.read<AuthService>();
    final error = await authService.uploadKtpImage(_ktpImage!);

    setState(() {
      _isUploading = false;
    });

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KTP berhasil diupload! Menunggu verifikasi admin.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi KTP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: user?.isVerified == true
                  ? Colors.green.shade50
                  : user?.ktpImageUrl != null
                      ? Colors.orange.shade50
                      : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      user?.isVerified == true
                          ? Icons.verified_user
                          : user?.ktpImageUrl != null
                              ? Icons.pending
                              : Icons.warning,
                      color: user?.isVerified == true
                          ? Colors.green.shade700
                          : user?.ktpImageUrl != null
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.isVerified == true
                                ? 'Terverifikasi'
                                : user?.ktpImageUrl != null
                                    ? 'Menunggu Verifikasi'
                                    : 'Belum Terverifikasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: user?.isVerified == true
                                  ? Colors.green.shade700
                                  : user?.ktpImageUrl != null
                                      ? Colors.orange.shade700
                                      : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.isVerified == true
                                ? 'Akun Anda sudah terverifikasi. Anda dapat memberikan suara.'
                                : user?.ktpImageUrl != null
                                    ? 'KTP Anda sedang ditinjau oleh admin.'
                                    : 'Upload foto KTP untuk memverifikasi identitas Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Info
            Text(
              'Foto KTP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload foto KTP yang jelas untuk verifikasi identitas. Pastikan seluruh KTP terlihat dengan jelas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            // KTP Image Preview
            GestureDetector(
              onTap: user?.isVerified == true ? null : _showPickerOptions,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _ktpImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _ktpImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : user?.ktpImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              user!.ktpImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk memilih foto KTP',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            // Upload Button
            if (user?.isVerified != true)
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadKtp,
                icon: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Mengupload...' : 'Upload KTP'),
              ),
            const SizedBox(height: 24),
            // Privacy Notice
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Keamanan Data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto KTP Anda hanya digunakan untuk verifikasi identitas dan disimpan dengan aman. Data Anda tidak akan dibagikan kepada pihak ketiga.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
}
