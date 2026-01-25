import 'dart:async';
import 'package:flutter/material.dart';

/// A [ChangeNotifier] that notifies its listeners whenever a [Stream] emits a value.
///
/// This is useful for [GoRouter]'s refreshListenable.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream].
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
