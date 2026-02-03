import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../injection_container.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/Profile');
          },
        ),
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
      ],
    );
  }

  _buildPage(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
        builder: (context, state) {
          if (state is RemoteArticlesLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is RemoteArticlesError) {
            return const Center(child: Icon(Icons.refresh));
          }
          if (state is RemoteArticlesDone) {
            if (state.articles!.isEmpty) {
              return const Center(child: Text("No articles yet. Create one!"));
            }
            return ListView.builder(
              itemCount: state.articles!.length,
              itemBuilder: (context, index) {
                return ArticleWidget(
                  article: state.articles![index],
                  onArticlePressed: (article) => _onArticlePressed(context, article),
                );
              },
            );
          }
           return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (sl<FirebaseAuth>().currentUser == null) {
              Navigator.pushNamed(context, '/Login');
              return;
          }
          await Navigator.pushNamed(context, '/CreateArticle');
          if (!context.mounted) return;
          context.read<RemoteArticlesBloc>().add(const GetArticles());
        },
        child: const Icon(Icons.add),
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
