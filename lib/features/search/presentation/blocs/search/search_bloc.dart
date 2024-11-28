import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/search/presentation/blocs/search/search_event.dart';
import 'package:blink/features/search/presentation/blocs/search/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<LoadRecentSearchEvent>((event, emit) {
      // 최근 검색어 로직
      emit(SearchLoaded(recentSearches: ['예시1', '예시2'], recommendedContents: []));
    });

    on<LoadRecommendedContentEvent>((event, emit) {
      // 추천 콘텐츠 로직
      emit(SearchLoaded(
        recentSearches: [],
        recommendedContents: ['추천1', '추천2', '추천3'],
      ));
    });
  }
}
