import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/plante.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String planteId) async {
    try {
      // Référence au fichier dans Storage
      final ref = _storage.ref().child('plantes/$planteId.jpg');
      
      // Upload du fichier
      final uploadTask = await ref.putFile(imageFile);
      
      // Récupérer l'URL de téléchargement
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('فشل رفع الصورة: $e');
    }
  }

  Future<void> savePlante(Plante plante) async {
    try {
      await _firestore
          .collection('plantes')
          .doc(plante.id)
          .set(plante.toFirestore());
    } catch (e) {
      throw Exception('فشل حفظ البيانات: $e');
    }
  }

  Future<List<Plante>> getAllPlantes() async {
    try {
      final querySnapshot = await _firestore
          .collection('plantes')
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Plante.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب البيانات: $e');
    }
  }
}
