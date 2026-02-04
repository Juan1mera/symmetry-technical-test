import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'create_article_state.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CreateArticleCubit(
    this._createArticleUseCase, 
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

      // Fetch user's display name from Firestore
      String authorName = 'Usuario Anónimo';
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final firstName = data?['firstName'] ?? '';
          final lastName = data?['lastName'] ?? '';
          authorName = '$firstName $lastName'.trim();
          
          // If both names are empty, try displayName from auth
          if (authorName.isEmpty) {
            authorName = user.displayName ?? 'Usuario Anónimo';
          }
        }
      } catch (e) {
        // If we can't fetch from Firestore, use displayName from auth
        authorName = user.displayName ?? 'Usuario Anónimo';
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
}
