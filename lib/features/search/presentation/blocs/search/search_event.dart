import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentSearchEvent extends SearchEvent {}

class LoadRecommendedContentEvent extends SearchEvent {}
