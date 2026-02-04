import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/edit_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

class MockCreateArticleUseCase extends Mock implements CreateArticleUseCase {}
class MockEditArticleUseCase extends Mock implements EditArticleUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late CreateArticleCubit cubit;
  late MockCreateArticleUseCase mockCreateArticleUseCase;
  late MockEditArticleUseCase mockEditArticleUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUpAll(() {
    registerFallbackValue(const ArticleEntity());
  });

  setUp(() {
    mockCreateArticleUseCase = MockCreateArticleUseCase();
    mockEditArticleUseCase = MockEditArticleUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    cubit = CreateArticleCubit(
      mockCreateArticleUseCase,
      mockEditArticleUseCase,
      mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tUser = UserEntity(uid: '123', email: 'test@test.com', firstName: 'Juan', lastName: 'Mera');
  const tTitle = 'Test Title';
  const tContent = 'Test Content';
  const tCategory = 'Tech';

  test('Initial state should be CreateArticleInitial', () {
    expect(cubit.state, isA<CreateArticleInitial>());
  });

  group('submitArticle', () {
    test('should emit [Loading, Success] when successful', () async {
      // arrange
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(() => mockCreateArticleUseCase(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));

      // assert later
      final expectedStates = [
        isA<CreateArticleLoading>(),
        isA<CreateArticleSuccess>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));

      // act
      await cubit.submitArticle(
        title: tTitle,
        content: tContent,
        category: tCategory,
      );
    });

    test('should emit [Loading, Error] when user is not authenticated', () async {
      // arrange
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => null);

      // assert later
      final expectedStates = [
        isA<CreateArticleLoading>(),
        isA<CreateArticleError>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));

      // act
      await cubit.submitArticle(
        title: tTitle,
        content: tContent,
        category: tCategory,
      );
    });
  });
}
