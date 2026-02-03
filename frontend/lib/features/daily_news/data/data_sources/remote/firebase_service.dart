import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadImage(File file) async {
    try {
      print("Starting image upload...");
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('media/articles/$fileName');

      print("Getting mime type...");
      // For simplicity we assume jpeg/png or let firebase detect, but passing explicit metadata fixes the NPE bug
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      
      UploadTask uploadTask = ref.putFile(file, metadata);
      
      print("Waiting for upload...");
      TaskSnapshot snapshot = await uploadTask;
      print("Upload finished. Getting URL...");
      String url = await snapshot.ref.getDownloadURL();
      print("Got URL: $url");
      return url;
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addArticle(ArticleModel article) async {
    try {
      print("Adding article to Firestore: ${article.title}");
      Map<String, dynamic> articleData = {
        'title': article.title,
        'content': article.content,
        'category': article.category,
        'thumbnailURL': article.urlToImage,
        'authorId': article.author,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('articles').add(articleData);
    } catch (e) {
      throw Exception('Failed to add article: $e');
    }
  }

  Future<List<ArticleModel>> getArticles() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('articles').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        return ArticleModel(
          id: data.containsKey('id') ? data['id'] : null, 
          author: data['authorId'],
          title: data['title'],
          description: data['content'],
          url: '', 
          urlToImage: data['thumbnailURL'],
          publishedAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toString() : '',
          content: data['content'],
          category: data['category'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch articles: $e');
    }
  }
}
