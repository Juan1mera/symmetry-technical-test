import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.principal,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: _buildBody(context),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onBackButtonTapped(context),
            child: const Icon(Ionicons.chevron_back, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleImageWithGradient(context),
          _buildArticleContent(),
        ],
      ),
    );
  }

  Widget _buildArticleImageWithGradient(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.network(
            article!.urlToImage!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.textoSecundario.withValues(alpha: 0.2),
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: AppColors.textoSecundario,
                  ),
                ),
              );
            },
          ),
          
          // Gradient overlay con transición suave al color de fondo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.principal.withValues(alpha: 0.3),
                    AppColors.principal.withValues(alpha: 0.8),
                    AppColors.principal,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
          
          // Category badge
          if (article!.category != null && article!.category!.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secundario,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  article!.category!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    return Container(
      color: AppColors.principal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article!.title!,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textoPrincipal,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 20),

          // Metadata Row: Category, Author, Date
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              // Category (si existe)
              if (article!.category != null && article!.category!.isNotEmpty)
                _buildMetadataChip(
                  icon: Icons.label_outline,
                  text: article!.category!,
                ),
              
              // Author (si existe)
              if (article!.author != null && article!.author!.isNotEmpty)
                _buildMetadataChip(
                  icon: Icons.person_outline,
                  text: article!.author!,
                ),
              
              // Date
              _buildMetadataChip(
                icon: Icons.access_time_outlined,
                text: DateFormatter.formatToSpanish(article!.publishedAt!),
                fullWidth: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Divider
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secundario.withValues(alpha: 0.3),
                  AppColors.secundario,
                  AppColors.secundario.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Description and Content
          Text(
            '${article!.description ?? ''}\\n\\n${article!.content ?? ''}',
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textoPrincipal,
              height: 1.7,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textoSecundario.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textoPrincipal.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.secundario,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textoPrincipal,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: fullWidth ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        backgroundColor: AppColors.secundario,
        onPressed: () => _onFloatingActionButtonPressed(context),
        child: const Icon(Ionicons.bookmark, color: Colors.white),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textoPrincipal,
        content: const Text('Artículo guardado exitosamente.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

