import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firebase_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/domain/usecases/create_article.dart';
import 'features/daily_news/domain/usecases/delete_article.dart';
import 'features/daily_news/domain/usecases/edit_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';
import 'core/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Data Sources
  sl.registerSingleton<NewsApiService>(NewsApiService(sl(), baseUrl: newsAPIBaseURL));
  sl.registerSingleton<FirebaseService>(FirebaseService());

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl())
  );
  
  //UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl())
  );

  sl.registerSingleton<SaveArticleUseCase>(
    SaveArticleUseCase(sl())
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

  sl.registerSingleton<CreateArticleUseCase>(
    CreateArticleUseCase(sl())
  );

  sl.registerSingleton<DeleteArticleUseCase>(
    DeleteArticleUseCase(sl())
  );

  sl.registerSingleton<EditArticleUseCase>(
    EditArticleUseCase(sl())
  );


  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl(),sl(),sl())
  );

  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );
  
  sl.registerFactory<CreateArticleCubit>(
    ()=> CreateArticleCubit(sl(), sl(), sl(), sl())
  );

  // Auth
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl(), sl(), sl())
  );

  sl.registerSingleton<LoginUseCase>(
    LoginUseCase(sl())
  );

  sl.registerSingleton<RegisterUseCase>(
    RegisterUseCase(sl())
  );

  sl.registerSingleton<UpdateProfileUseCase>(
    UpdateProfileUseCase(sl())
  );

  sl.registerSingleton<UploadProfileImageUseCase>(
    UploadProfileImageUseCase(sl())
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl(), sl())
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(sl(), sl())
  );

}