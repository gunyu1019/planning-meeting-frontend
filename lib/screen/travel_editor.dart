import 'package:flutter/material.dart';

import '../widget/map_component.dart';
import '../widget/menu_component.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double totalWidth = constraints.maxWidth;
          double rightWidth = totalWidth / 3 < 10 ? 100 : totalWidth / 3;
          return Row(
            children: [
              Expanded(child: const MapComponent()),
              SizedBox(width: rightWidth, child: const MenuComponent()),
            ],
          );
        },
      ),
    );
  }
}
