import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../rbac/auth_session.dart';

/// Renders [child] only when the current session holds [perm].
class PermGate extends ConsumerWidget {
  const PermGate({
    required this.perm,
    required this.child,
    this.fallback,
    super.key,
  });

  final String perm;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null || !session.can(perm)) {
      return fallback ?? const SizedBox.shrink();
    }
    return child;
  }
}
