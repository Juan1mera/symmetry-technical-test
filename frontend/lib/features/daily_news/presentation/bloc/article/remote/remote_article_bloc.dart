import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/edit_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent,RemoteArticlesState> {
  
  final GetArticleUseCase _getArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final EditArticleUseCase _editArticleUseCase;
  
  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._deleteArticleUseCase,
    this._editArticleUseCase,
  ) : super(const RemoteArticlesLoading()){
    on <GetArticles> (onGetArticles);
    on <DeleteArticle> (onDeleteArticle);
    on <UpdateArticle> (onUpdateArticle);
  }


  void onGetArticles(GetArticles event, Emitter < RemoteArticlesState > emit) async {
    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess && dataState.data != null) {
      emit(
        RemoteArticlesDone(dataState.data!)
      );
    }
    
    if (dataState is DataFailed) {
      emit(
        RemoteArticlesError(dataState.error!)
      );
    }
  }

  void onDeleteArticle(DeleteArticle event, Emitter<RemoteArticlesState> emit) async {
     final result = await _deleteArticleUseCase(params: event.article);
     if (result is DataSuccess) {
       add(const GetArticles());
     }
  }

  void onUpdateArticle(UpdateArticle event, Emitter<RemoteArticlesState> emit) async {
     final result = await _editArticleUseCase(params: event.article);
     if (result is DataSuccess) {
       add(const GetArticles());
     }
  }
  
}