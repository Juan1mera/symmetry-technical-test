import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadImage(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('media/articles/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addArticle(ArticleModel article) async {
    try {
      // Use set instead of add to control ID if needed, but add is fine for auto-ID
      // However, we need to map the model to JSON. 
      // The schema requires specific fields.
      
      Map<String, dynamic> articleData = {
        'title': article.title,
        'content': article.content,
        'category': article.category,
        'thumbnailURL': article.urlToImage, // Mapping urlToImage to thumbnailURL
        'authorId': article.author, // Assuming author field in entity holds the ID
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
      };

      await _firestore.collection('articles').add(articleData);
    } catch (e) {
      throw Exception('Failed to add article: $e');
    }
  }
}
