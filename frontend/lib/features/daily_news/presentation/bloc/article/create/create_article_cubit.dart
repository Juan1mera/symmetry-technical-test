import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/edit_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_current_user.dart';
import 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final EditArticleUseCase _editArticleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  CreateArticleCubit(
    this._createArticleUseCase, 
    this._editArticleUseCase, 
    this._getCurrentUserUseCase,
  ) : super(CreateArticleInitial());

  Future<void> submitArticle({
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    emit(CreateArticleLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user == null) {
          emit(const CreateArticleError("Usuario no autenticado"));
          return;
      }

      String authorName = user.fullName ?? 'Usuario Anónimo';

      final article = ArticleEntity(
        title: title,
        content: content,
        category: category,
        urlToImage: imagePath,
        author: authorName,
        authorId: user.uid, 
        publishedAt: DateTime.now().toIso8601String(),
      );

      final result = await _createArticleUseCase.call(params: article);
      
      if (result is DataSuccess) {
        emit(CreateArticleSuccess());
      } else {
        emit(CreateArticleError(result.error?.toString() ?? "Error desconocido al crear el artículo"));
      }
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
      final user = await _getCurrentUserUseCase();
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

      final result = await _editArticleUseCase.call(params: updatedArticle);

      if (result is DataSuccess) {
        emit(CreateArticleSuccess());
      } else {
        emit(CreateArticleError(result.error?.toString() ?? "Error desconocido al actualizar el artículo"));
      }
    } catch (e) {
      emit(CreateArticleError(e.toString()));
    }
  }
}
