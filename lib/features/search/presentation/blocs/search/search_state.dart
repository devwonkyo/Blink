import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoaded extends SearchState {
  final List<String> recentSearches;
  final List<String> recommendedContents;

  SearchLoaded({
    required this.recentSearches,
    required this.recommendedContents,
  });

  @override
  List<Object?> get props => [recentSearches, recommendedContents];
}
