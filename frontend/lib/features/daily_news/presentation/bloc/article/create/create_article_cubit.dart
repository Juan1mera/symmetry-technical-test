import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;

  CreateArticleCubit(this._createArticleUseCase) : super(CreateArticleInitial());

  Future<void> submitArticle({
    required String title,
    required String content,
    required String category,
    String? imagePath,
  }) async {
    emit(CreateArticleLoading());
    try {
      final article = ArticleEntity(
        title: title,
        content: content,
        category: category,
        urlToImage: imagePath,
        author: 'current_user', // Replace with actual user ID if auth is implemented
        publishedAt: DateTime.now().toIso8601String(),
      );

      await _createArticleUseCase.call(params: article);
      emit(CreateArticleSuccess());
    } catch (e) {
      emit(CreateArticleError(e.toString()));
    }
  }
}
