import 'package:flutter/material.dart';

class Supplied extends StatelessWidget {
  final int supplied;

  const Supplied({super.key, required this.supplied});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.keyboard_arrow_up),
        Text('$supplied',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
        Text('Supplied',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
