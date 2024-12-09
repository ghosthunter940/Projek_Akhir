import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk menyimpan laporan
  Future<void> saveReport(String userId, String text, String fileUrl) async {
    try {
      await _firestore.collection('reports').add({
        'userId': userId,
        'text': text,
        'fileUrl': fileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore save error: $e');
      throw Exception('Failed to save report');
    }
  }
}
