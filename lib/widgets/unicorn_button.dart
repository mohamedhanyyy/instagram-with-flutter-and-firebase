import 'package:flutter/material.dart';

final kInnerDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.white),
  borderRadius: BorderRadius.circular(20),
);
// border for all 3 colors
final kGradientBoxDecoration = BoxDecoration(
  gradient: LinearGradient(
      colors: [Colors.yellow.shade600, Colors.orange, Colors.red]),
  border: Border.all(
    color: Colors.amber, //kHintColor, so this should be changed?
  ),
  borderRadius: BorderRadius.circular(20),
);

class GradientText extends StatelessWidget {
  const GradientText(  {
    required this.text,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
      child: Text(text, style: style),
    );
  }
}