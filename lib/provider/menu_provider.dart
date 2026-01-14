import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


class MenuControllerNotifier extends StateNotifier<String> {
  MenuControllerNotifier() : super("setup");

  void changePage(String pageId) => state = pageId;
}


final menuControllerProvider = StateNotifierProvider<MenuControllerNotifier, String>((ref)
  => MenuControllerNotifier()
);
