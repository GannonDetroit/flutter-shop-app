import 'package:flutter/material.dart';

//<T> is generic type used for generic classes like MaterialPageRoute.
class CustomRoute<T> extends MaterialPageRoute<T> {
  //make a constructor that has builder and settings just like the normal MaterialPageRoute class so this custom version operates the same way without breaking.
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(builder: builder, settings: settings);

//this allows you to build your own custom animations between routes.
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuider extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (route.settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
