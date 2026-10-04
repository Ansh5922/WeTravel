import 'package:flutter/material.dart';

/// Reusable avatar stack widget showing overlapping traveler profile pictures.
class AvatarStack extends StatelessWidget {
  final List<String> avatarPaths;
  final double size;
  final double overlap;
  final Color borderColor;
  final double borderWidth;

  const AvatarStack({
    super.key,
    required this.avatarPaths,
    this.size = 24.0,
    this.overlap = 8.0,
    this.borderColor = Colors.white,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarPaths.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: size,
      width: size + (avatarPaths.length - 1) * (size - overlap),
      child: Stack(
        children: List.generate(avatarPaths.length, (index) {
          return Positioned(
            left: index * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                image: DecorationImage(
                  image: AssetImage(avatarPaths[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
