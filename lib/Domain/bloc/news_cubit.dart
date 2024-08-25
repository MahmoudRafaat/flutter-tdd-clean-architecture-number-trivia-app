import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:training/Data/models/news.dart';
import 'package:training/Domain/bloc/news_state.dart';


class NewsCubit extends Cubit<NewsState> {
  final Dio _dio;
  late List<News> news;


  NewsCubit() : _dio = Dio(), super(NewsInitial());

  Future<void> getAllNews() async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts');
      final newsList = (response.data as List<dynamic>)
          .map((json) => News.fromJson(json))
          .toList();
      news=newsList;
      emit(NewsLoaded(newsList));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}

