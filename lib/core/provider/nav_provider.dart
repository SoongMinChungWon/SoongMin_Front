import 'package:flutter_riverpod/flutter_riverpod.dart';

// NavState 클래스: 상태를 표현하는 클래스
class NavState {
  final String title;

  NavState({this.title = '숭민청원'});
}

// NavStateNotifier 클래스: StateNotifier를 확장하여 NavState 상태를 관리
class NavStateNotifier extends StateNotifier<NavState> {
  NavStateNotifier() : super(NavState());

  // 상태를 업데이트하는 메서드
  void updateTitle(String newTitle) {
    state = NavState(title: newTitle);
  }
}

// StateNotifierProvider를 사용하여 NavStateNotifier를 제공합니다.
final navStateProvider =
    StateNotifierProvider<NavStateNotifier, NavState>((ref) {
  return NavStateNotifier();
});
