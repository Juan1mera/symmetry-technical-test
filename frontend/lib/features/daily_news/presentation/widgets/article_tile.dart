import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable; // Whether the article can be removed from saved list
  final bool isOwner; // Shows edit and delete buttons for the owner
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onEdit;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,

    this.isRemovable = false,
    this.isOwner = false,
    this.onRemove,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Card(
          elevation: 4,
          shadowColor: AppColors.textoPrincipal.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context),
              _buildContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Thumbnail image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: CachedNetworkImage(
            imageUrl: article!.urlToImage!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            progressIndicatorBuilder: (context, url, downloadProgress) => Container(
              color: AppColors.textoSecundario.withValues(alpha: 0.1),
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.textoSecundario.withValues(alpha: 0.1),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.textoSecundario,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
        
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        
        // Category badge
        if (article!.category != null && article!.category!.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secundario,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                article!.category!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        

        
        // Owner Actions (Edit / Delete)
        if (isOwner)
          Positioned(
            top: 12,
            right: 12,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) onEdit!(article!);
                if (value == 'delete' && onRemove != null) onRemove!(article!);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.textoPrincipal, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.secundario, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: AppColors.secundario)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: AppColors.textoPrincipal,
                  size: 18,
                ),
              ),
            ),
          )
        else if (isRemovable!)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.secundario,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article!.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.textoPrincipal,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          if (article!.description != null && article!.description!.isNotEmpty)
            Text(
              article!.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textoSecundario,
                height: 1.4,
              ),
            ),

          const SizedBox(height: 12),

          // Author and Date
          Row(
            children: [
              // Author
              if (article!.author != null && article!.author!.isNotEmpty) ...[
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.secundario,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    article!.author!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoPrincipal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Date
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.secundario,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatToShort(article!.publishedAt!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }
}
