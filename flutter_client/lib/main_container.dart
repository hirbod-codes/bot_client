import 'package:flutter/material.dart';
import 'package:flutter_client/Pages/main_page.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.background,
              ],
              tileMode: TileMode.clamp,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: const MainPage(),
        ),
      );
}
