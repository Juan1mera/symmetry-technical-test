import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/edit_article.dart';
import 'create_article_state.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final EditArticleUseCase _editArticleUseCase;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CreateArticleCubit(
    this._createArticleUseCase, 
    this._editArticleUseCase, 
    this._firebaseAuth,
    this._firestore,
  ) : super(CreateArticleInitial());

  Future<void> submitArticle({
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    emit(CreateArticleLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
          emit(const CreateArticleError("Usuario no autenticado"));
          return;
      }

      // Obtener el nombre del autor desde Firestore
      String authorName = '';
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final firstName = data?['firstName'] as String? ?? '';
          final lastName = data?['lastName'] as String? ?? '';
          authorName = '$firstName $lastName'.trim();
        }
      } catch (_) {}

      // Si falla Firestore o está vacío, intentar con el displayName de Auth
      if (authorName.isEmpty) {
        authorName = user.displayName ?? '';
      }

      // Fallback final si no hay nombre en ninguna fuente
      if (authorName.isEmpty) {
        authorName = 'Usuario Anónimo';
      }

      final article = ArticleEntity(
        title: title,
        content: content,
        category: category,
        urlToImage: imagePath,
        author: authorName,
        authorId: user.uid, 
        publishedAt: DateTime.now().toIso8601String(),
      );

      await _createArticleUseCase.call(params: article);
      emit(CreateArticleSuccess());
    } catch (e) {
      emit(CreateArticleError(e.toString()));
    }
  }

  Future<void> updateArticle({
    required ArticleEntity originalArticle,
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    emit(CreateArticleLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
          emit(const CreateArticleError("Usuario no autenticado"));
          return;
      }
      
      final updatedArticle = ArticleEntity(
        id: originalArticle.id,
        documentId: originalArticle.documentId,
        title: title,
        content: content,
        category: category,
        urlToImage: imagePath ?? originalArticle.urlToImage, 
        author: originalArticle.author,
        authorId: originalArticle.authorId,
        publishedAt: originalArticle.publishedAt,
      );

      await _editArticleUseCase.call(params: updatedArticle);
      emit(CreateArticleSuccess());
    } catch (e) {
      emit(CreateArticleError(e.toString()));
    }
  }
}
