import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/firebase_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final AppDatabase _appDatabase;
  final FirebaseService _firebaseService;
  
  ArticleRepositoryImpl(this._appDatabase, this._firebaseService);
  
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
  Future<DataState<void>> createArticle(ArticleEntity article) async {
    try {
      String? imageUrl = article.urlToImage;
      
      // Check if the image is a local path. If it is, upload it to Firebase 
      // Storage first to get a permanent URL. If don't do this, the image 
      // will only be visible on the device that uploaded it.
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
        authorId: article.authorId, 
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: imageUrl, 
        publishedAt: article.publishedAt,
        content: article.content,
        category: article.category
      );

      await _firebaseService.addArticle(newArticle);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }


  @override
  Future<DataState<void>> deleteRemoteArticle(ArticleEntity article) async {
    try {
      if (article.documentId != null) {
        await _firebaseService.deleteArticle(article.documentId!);
        return const DataSuccess(null);
      } else {
        return DataFailed(Exception('Article does not have a document ID'));
      }
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<void>> editRemoteArticle(ArticleEntity article) async {
    try {
      String? imageUrl = article.urlToImage;
      
      // When editing, user only upload the image if it's a new local file.
      // Remote URLs (starting with http) are kept as is.
      if (imageUrl != null && !imageUrl.startsWith('http') && imageUrl.isNotEmpty) {
         File imageFile = File(imageUrl);
         if (await imageFile.exists()) {
           imageUrl = await _firebaseService.uploadImage(imageFile);
         }
      }

      ArticleModel updatedArticle = ArticleModel.fromEntity(article);
      // need to re-create the model with the new image URL if it changed
      if (imageUrl != article.urlToImage) {
        updatedArticle = ArticleModel(
          id: article.id,
          documentId: article.documentId,
          author: article.author,
          authorId: article.authorId,
          title: article.title,
          description: article.description,
          url: article.url,
          urlToImage: imageUrl,
          publishedAt: article.publishedAt,
          content: article.content,
          category: article.category
        );
      }

      await _firebaseService.updateArticle(updatedArticle);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }
}