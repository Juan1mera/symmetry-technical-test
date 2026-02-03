import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';
import '../data_sources/remote/firebase_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirebaseService _firebaseService;
  
  ArticleRepositoryImpl(this._newsApiService, this._appDatabase, this._firebaseService);
  
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
   try {
    final articles = await _firebaseService.getArticles();
    return DataSuccess(articles);
   } catch (e){
    return DataFailed(e is Exception ? e : Exception(e.toString()));
   }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }
  
  @override
  Future<void> createArticle(ArticleEntity article) async {
    try {
      String? imageUrl = article.urlToImage;
      
      // If the image is a local file path, upload it
      if (imageUrl != null && !imageUrl.startsWith('http')) {
         File imageFile = File(imageUrl);
         if (await imageFile.exists()) {
           imageUrl = await _firebaseService.uploadImage(imageFile);
         }
      }

      // Create a model with the updated URL (when uploaded)
      ArticleModel newArticle = ArticleModel(
        id: article.id,
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: imageUrl, 
        publishedAt: article.publishedAt,
        content: article.content,
        category: article.category
      );

      await _firebaseService.addArticle(newArticle);

    } catch (e) {
      throw Exception('Failed to create article: $e');
    }
  }
}