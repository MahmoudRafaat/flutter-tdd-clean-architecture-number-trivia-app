import 'package:training/Data/models/news.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoaded extends NewsState {
  final List<News> newsList;

  NewsLoaded(this.newsList);
}
class NewsError extends NewsState {
  final String errorMessage;
  NewsError(this.errorMessage);
}