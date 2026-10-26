import 'package:flutter/widgets.dart';

/// Tells a screen it is on top again (`RouteAware.didPopNext`): the chat
/// shell shows a share that arrived while another page was open.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
