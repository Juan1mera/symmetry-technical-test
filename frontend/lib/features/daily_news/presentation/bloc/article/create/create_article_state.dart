import 'package:equatable/equatable.dart';

abstract class CreateArticleState extends Equatable {
  const CreateArticleState();

  @override
  List<Object> get props => [];
}

class CreateArticleInitial extends CreateArticleState {}

class CreateArticleLoading extends CreateArticleState {}

class CreateArticleSuccess extends CreateArticleState {}

class CreateArticleError extends CreateArticleState {
  final String message;

  const CreateArticleError(this.message);

  @override
  List<Object> get props => [message];
}
