import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/router.dart';
import 'package:hermes/app/routes.dart';

/// A page that only says where it is.
class _Page extends StatelessWidget {
  const _Page(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(name));
}

void main() {
  late GoRouter router;

  String location() =>
      router.routerDelegate.currentConfiguration.uri.toString();

  Future<void> pumpRouter(WidgetTester tester, String initial) async {
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initial,
      onEnter: refuseExternal,
      routes: [
        GoRoute(path: Routes.home, builder: (_, _) => const _Page('home')),
        GoRoute(
          path: Routes.chat,
          builder: (_, state) =>
              _Page('chat ${state.pathParameters[Routes.profileParam]}'),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (_, _) => const _Page('settings'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('with only a chat open, a tap replaces it: back leaves the app', (
    tester,
  ) async {
    await pumpRouter(tester, Routes.chatPath('atlas'));

    openFromOutside(router, Routes.chatPath('nova'));
    await tester.pumpAndSettle();

    expect(location(), Routes.chatPath('nova'));
    expect(rootNavigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('over Settings a tap pushes the chat: Settings is kept below', (
    tester,
  ) async {
    await pumpRouter(tester, Routes.chatPath('atlas'));
    router.push<void>(Routes.settings).ignore();
    await tester.pumpAndSettle();

    openFromOutside(router, Routes.chatPath('nova'));
    await tester.pumpAndSettle();
    expect(find.text('chat nova'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('settings'), findsOneWidget);
  });

  testWidgets('a link that reaches the router changes nothing', (tester) async {
    await pumpRouter(tester, Routes.chatPath('atlas'));
    router.push<void>(Routes.settings).ignore();
    await tester.pumpAndSettle();

    router.go('pomelu://chat?profile=nova');
    await tester.pumpAndSettle();
    router.go('/?profile=nova');
    await tester.pumpAndSettle();

    expect(find.text('settings'), findsOneWidget);
    expect(find.text('chat nova', skipOffstage: false), findsNothing);
    expect(find.text('home', skipOffstage: false), findsNothing);
  });
}
