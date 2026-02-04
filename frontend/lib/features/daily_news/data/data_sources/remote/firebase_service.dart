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

      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      
      UploadTask uploadTask = ref.putFile(file, metadata);
      
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addArticle(ArticleModel article) async {
    try {
      Map<String, dynamic> articleData = {
        'title': article.title,
        'content': article.content,
        'category': article.category,
        'thumbnailURL': article.urlToImage ?? "", 
        'author': article.author, 
        'authorId': article.authorId, 
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
          documentId: doc.id,
          author: data['author'] ?? 'Anonymous User', 
          authorId: data['authorId'], 
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

  
  Future<void> deleteArticle(String documentId) async {
    try {
      await _firestore.collection('articles').doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete article: $e');
    }
  }

  Future<void> updateArticle(ArticleModel article) async {
    try {
      if (article.documentId == null) {
        throw Exception('Article documentId is null');
      }

      Map<String, dynamic> articleData = {
        'title': article.title,
        'content': article.content,
        'category': article.category,
        'thumbnailURL': article.urlToImage ?? "",
      };
      
      if (article.author != null) articleData['author'] = article.author;

      await _firestore.collection('articles').doc(article.documentId).update(articleData);
    } catch (e) {
      throw Exception('Failed to update article: $e');
    }
  }
}

