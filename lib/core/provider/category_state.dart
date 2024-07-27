import 'package:flutter_riverpod/flutter_riverpod.dart';

// 카테고리 상태 클래스
class CategoryState {
  String? selectedCategory;

  CategoryState({this.selectedCategory});
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState(selectedCategory: ''));

  // 카테고리 선택을 업데이트하는 메서드
  void updateCategory(String newCategory) {
    state = CategoryState(selectedCategory: newCategory);
  }
}

// StateNotifierProvider를 사용하여 CategoryNotifier를 제공합니다.
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier();
});
