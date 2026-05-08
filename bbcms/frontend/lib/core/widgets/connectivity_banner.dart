import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Slim banner shown above the app body when the device is offline.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({required this.child, super.key});
  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  late final Stream<List<ConnectivityResult>> _stream =
      Connectivity().onConnectivityChanged;
  bool _online = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: _stream,
      builder: (context, snap) {
        final results = snap.data ?? const [ConnectivityResult.wifi];
        _online = !results.every((r) => r == ConnectivityResult.none);
        return Column(
          children: [
            if (!_online)
              Container(
                width: double.infinity,
                color: AppColors.warning,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: const Text(
                  'Hors ligne — les changements seront synchronisés.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}
