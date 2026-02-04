import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../injection_container.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'News',
                style: TextStyle(
                  fontFamily: 'Butler',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoPrincipal,
                  height: 1.0,
                ),
              ),
              Text(
                'Noticias Diarias',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textoSecundario,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderIcon(
                context, 
                Icons.bookmark_border, 
                () => _onShowSavedArticlesViewTapped(context)
              ),
              const SizedBox(width: 12),
              _buildHeaderIcon(
                context, 
                Icons.person_outline, 
                () {
                  Navigator.pushNamed(context, '/Profile');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textoSecundario.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.textoPrincipal,
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.principal,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(context),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
                builder: (context, state) {
                  if (state is RemoteArticlesLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (state is RemoteArticlesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 50, color: AppColors.textoSecundario),
                          const SizedBox(height: 10),
                          Text("Error cargando noticias", style: TextStyle(color: AppColors.textoSecundario)),
                        ],
                      ),
                    );
                  }
                  if (state is RemoteArticlesDone) {
                    if (state.articles!.isEmpty) {
                      return const Center(child: Text("No hay noticias aún. ¡Crea una!"));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: state.articles!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArticleWidget(
                            article: state.articles![index],
                            onArticlePressed: (article) => _onArticlePressed(context, article),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secundario,
        onPressed: () async {
          if (sl<FirebaseAuth>().currentUser == null) {
              Navigator.pushNamed(context, '/Login');
              return;
          }
          await Navigator.pushNamed(context, '/CreateArticle');
          if (!context.mounted) return;
          context.read<RemoteArticlesBloc>().add(const GetArticles());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
