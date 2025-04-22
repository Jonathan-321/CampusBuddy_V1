import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/news.dart';
import '../../../data/models/news_model.dart';

// Events
abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNews extends NewsEvent {}

class FilterNewsByCategory extends NewsEvent {
  final String category;

  const FilterNewsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchNews extends NewsEvent {
  final String query;

  const SearchNews(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<News> allNews;
  final List<News> filteredNews;
  final String currentFilter;

  const NewsLoaded({
    required this.allNews,
    required this.filteredNews,
    this.currentFilter = 'All',
  });

  @override
  List<Object?> get props => [allNews, filteredNews, currentFilter];

  NewsLoaded copyWith({
    List<News>? allNews,
    List<News>? filteredNews,
    String? currentFilter,
  }) {
    return NewsLoaded(
      allNews: allNews ?? this.allNews,
      filteredNews: filteredNews ?? this.filteredNews,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc() : super(NewsInitial()) {
    on<LoadNews>(_onLoadNews);
    on<FilterNewsByCategory>(_onFilterNewsByCategory);
    on<SearchNews>(_onSearchNews);
  }

  void _onLoadNews(LoadNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      // In a real app, this would come from a repository
      final news = NewsModel.getMockNews();
      emit(NewsLoaded(allNews: news, filteredNews: news));
    } catch (e) {
      emit(NewsError('Failed to load news: $e'));
    }
  }

  void _onFilterNewsByCategory(FilterNewsByCategory event, Emitter<NewsState> emit) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      final category = event.category;
      final filteredNews = category == 'All'
          ? currentState.allNews
          : currentState.allNews
              .where((news) => news.category.toLowerCase() == category.toLowerCase())
              .toList();
      
      emit(currentState.copyWith(
        filteredNews: filteredNews,
        currentFilter: category,
      ));
    }
  }

  void _onSearchNews(SearchNews event, Emitter<NewsState> emit) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      final query = event.query.toLowerCase();
      final filteredNews = query.isEmpty
          ? currentState.allNews
          : currentState.allNews.where((news) {
              return news.title.toLowerCase().contains(query) ||
                  news.summary.toLowerCase().contains(query) ||
                  news.content.toLowerCase().contains(query) ||
                  news.author.toLowerCase().contains(query) ||
                  news.category.toLowerCase().contains(query) ||
                  news.tags.any((tag) => tag.toLowerCase().contains(query));
            }).toList();
      
      emit(currentState.copyWith(
        filteredNews: filteredNews,
      ));
    }
  }
}
