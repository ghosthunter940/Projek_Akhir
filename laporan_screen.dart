import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LaporanScreen extends StatefulWidget {
  @override
  _LaporanScreenState createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final TextEditingController textController = TextEditingController();
  File? selectedFile;
  bool isLoading = false;

  // Fungsi untuk memilih file dari galeri
  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengunggah laporan
  Future<void> _submitReport() async {
    if (textController.text.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi laporan dan pilih file terlebih dahulu!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String fileUrl = await StorageService().uploadFile(
        'uploads/${DateTime.now().millisecondsSinceEpoch}',
        selectedFile!,
      );

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirestoreService().saveReport(
          currentUser.uid,
          textController.text.trim(),
          fileUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan berhasil dikirim!')),
        );
        textController.clear();
        setState(() {
          selectedFile = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Laporan'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Isi Laporan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.upload_file),
              label: Text('Pilih File'),
            ),
            if (selectedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('File terpilih: ${selectedFile!.path}'),
              ),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitReport,
                    child: Text('Kirim Laporan'),
                  ),
          ],
        ),
      ),
    );
  }
}
