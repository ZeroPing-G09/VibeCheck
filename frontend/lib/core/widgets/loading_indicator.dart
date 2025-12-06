import 'package:flutter/material.dart';
import 'loading_state.dart';

@Deprecated('Use LoadingState instead')
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingState();
  }
}
