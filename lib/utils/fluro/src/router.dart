/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/fluro/src/tree.dart';
import 'package:lazycook/utils/logger.dart';

class Router {
  static final appRouter = Router();

  /// The tree structure that stores the defined routes
  final RouteTree _routeTree = RouteTree();

  /// Generic handler for when a route has not been defined
  Handler notFoundHandler;

  Handler redirectHandler;

  Interceptor interceptor;

  /// Creates a [PageRoute] definition for the passed [RouteHandler]. You can optionally provide a default transition type.
  void define(String routePath,
      {@required Handler handler, TransitionType transitionType}) {
    _routeTree.addRoute(
      AppRoute(routePath, handler, transitionType: transitionType),
    );
  }

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch match(String path) {
    return _routeTree.matchRoute(path);
  }

  void pop(BuildContext context) => Navigator.pop(context);

  ///
  Future navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition,
      RoutePredicate predicate,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionBuilder}) {
    RouteMatch routeMatch = matchRoute(context, path,
        transitionType: transition,
        transitionsBuilder: transitionBuilder,
        transitionDuration: transitionDuration);
    Route<dynamic> route = routeMatch.route;
    Completer completer = Completer();
    Future future = completer.future;
    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      completer.complete("Non visual route type.");
    } else {
      if (route == null && notFoundHandler != null) {
        route = _notFoundRoute(context, path);
      }
      if (route != null) {
        if (clearStack) {
          future =
              Navigator.pushAndRemoveUntil(context, route, predicate);
        } else {
          future = replace
              ? Navigator.pushReplacement(context, route)
              : Navigator.push(context, route);
        }
        completer.complete();
      } else {
        String error = "No registered route was found to handle '$path'.";
        print(error);
        completer.completeError(RouteNotFoundException(error, path));
      }
    }

    return future;
  }

  ///
  Route<Null> _notFoundRoute(BuildContext context, String path) {
    RouteCreator<Null> creator =
        (RouteSettings routeSettings, Map<String, List<String>> parameters) {
      if (Platform.isIOS) {
        return CupertinoPageRoute<Null>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return notFoundHandler
                  .handlerFunc(context, parameters, extra: {"path": path});
            });
      } else {
        return MaterialPageRoute<Null>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return notFoundHandler
                  .handlerFunc(context, parameters, extra: {"path": path});
            });
      }
    };
    return creator(RouteSettings(name: path), null);
  }

  ///
  Route<dynamic> _redirectRoute(BuildContext context, String path) {
    RouteCreator<dynamic> creator =
        (RouteSettings routeSettings, Map<String, List<String>> parameters) {
      if (Platform.isIOS) {
        return CupertinoPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (BuildContext context) {
              if (redirectHandler == null)
                return notFoundHandler
                    .handlerFunc(context, parameters, extra: {"path": path});
              return redirectHandler
                  .handlerFunc(context, parameters, extra: {"path": path});
            });
      } else {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: true,
            builder: (BuildContext context) {
              if (redirectHandler == null)
                return notFoundHandler
                    .handlerFunc(context, parameters, extra: {"path": path});
              return redirectHandler
                  .handlerFunc(context, parameters, extra: {"path": path});
            });
      }
    };
    return creator(RouteSettings(name: path), null);
  }

  ///
  RouteMatch matchRoute(BuildContext buildContext, String path,
      {RouteSettings routeSettings,
      TransitionType transitionType,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionsBuilder}) {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = RouteSettings(name: path);
    }
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;
    Handler handler = (route != null ? route.handler : notFoundHandler);
    var transition = transitionType;
    if (transitionType == null) {
      transition = route != null ? route.transitionType : TransitionType.native;
    }
    if (route == null && notFoundHandler == null) {
      return RouteMatch(
          matchType: RouteMatchType.noMatch,
          errorMessage: "No matching route was found");
    }
    Map<String, List<String>> parameters =
        match?.parameters ?? <String, List<String>>{};
    if (route?.handler?.intercept == true &&
        interceptor != null &&
        !interceptor()) {
      return RouteMatch(
          matchType: RouteMatchType.intercept,
          route: _redirectRoute(buildContext, path),
          errorMessage: "your route has been intercepted");
    }

    if (handler.type == HandlerType.function) {
      handler.handlerFunc(buildContext, parameters);
      return RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    RouteCreator creator =
        (RouteSettings routeSettings, Map<String, List<String>> parameters) {
      bool isNativeTransition = (transition == TransitionType.native ||
          transition == TransitionType.nativeModal);
      if (isNativeTransition) {
        if (Platform.isIOS) {
          return CupertinoPageRoute<dynamic>(
              settings: routeSettings,
              fullscreenDialog: transition == TransitionType.nativeModal,
              builder: (BuildContext context) {
                Widget targetWidget = handler.handlerFunc(context, parameters);
                return targetWidget;
              });
        } else {
          return MaterialPageRoute<dynamic>(
              settings: routeSettings,
              fullscreenDialog: transition == TransitionType.nativeModal,
              builder: (BuildContext context) {
                return handler.handlerFunc(context, parameters);
              });
        }
      } else if (transition == TransitionType.material ||
          transition == TransitionType.materialFullScreenDialog) {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                transition == TransitionType.materialFullScreenDialog,
            builder: (BuildContext context) {
              return handler.handlerFunc(context, parameters);
            });
      } else if (transition == TransitionType.cupertino ||
          transition == TransitionType.cupertinoFullScreenDialog) {
        return CupertinoPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                transition == TransitionType.cupertinoFullScreenDialog,
            builder: (BuildContext context) {
              return handler.handlerFunc(context, parameters);
            });
      } else {
        var routeTransitionsBuilder;
        if (transition == TransitionType.custom) {
          routeTransitionsBuilder = transitionsBuilder;
        } else {
          routeTransitionsBuilder = _standardTransitionsBuilder(transition);
        }
        return PageRouteBuilder<dynamic>(
          settings: routeSettings,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return handler.handlerFunc(context, parameters);
          },
          transitionDuration: transitionDuration,
          transitionsBuilder: routeTransitionsBuilder,
        );
      }
    };
    return RouteMatch(
      matchType: RouteMatchType.visual,
      route: creator(settingsToUse, parameters),
    );
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);
        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<dynamic> generator(RouteSettings routeSettings) {
    Logger("").log("generator routeSettings = ${routeSettings.name}");
    RouteMatch match =
        matchRoute(null, routeSettings.name, routeSettings: routeSettings);
    return match.route;
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
