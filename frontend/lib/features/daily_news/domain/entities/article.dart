import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable{
  final int ? id;
  final String ? documentId; // ID del documento en Firestore

  final String ? author;
  final String ? authorId; // ID del usuario para reglas de seguridad
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;
  final String ? category;

  const ArticleEntity({
    this.id,
    this.documentId,
    this.author,
    this.authorId,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  @override
  List < Object ? > get props {
    return [
      id,
      documentId,
      author,
      authorId,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      category,
    ];
  }
}