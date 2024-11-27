class SearchUseCase {
  Future<List<String>> getRecentSearches() async {
    // 로컬 데이터베이스 또는 API에서 최근 검색어 가져오기
    return ['예시1', '예시2'];
  }

  Future<List<String>> getRecommendedContents() async {
    // 추천 콘텐츠 가져오기
    return ['추천1', '추천2', '추천3'];
  }
}
