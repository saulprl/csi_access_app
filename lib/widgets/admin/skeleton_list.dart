import 'package:flutter/material.dart';

import 'package:skeleton_animation/skeleton_animation.dart';

class SkeletonList extends StatelessWidget {
  final int count;
  final double height;

  const SkeletonList({
    this.count = 3,
    this.height = 52.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: count,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Skeleton(
                height: height,
                borderRadius: BorderRadius.circular(16.0),
              ),
            );
          },
        )
      ],
    );
  }
}
