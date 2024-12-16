import 'package:flutter/material.dart';

class Burned extends StatelessWidget {
  final int burned;

  const Burned({super.key, required this.burned});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.keyboard_arrow_down),
        Text('$burned',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
        Text('Burned',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
