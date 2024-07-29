import 'package:flutter_riverpod/flutter_riverpod.dart';

// 카테고리 상태 클래스
class SearchState {
  String? searchContent;

  SearchState({this.searchContent});
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState(searchContent: ''));

  // 카테고리 선택을 업데이트하는 메서드
  void updateSearch(String newSearch) {
    state = SearchState(searchContent: newSearch);
  }
}
// 카테고리 상태를 관리하는 StateNotifier

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
