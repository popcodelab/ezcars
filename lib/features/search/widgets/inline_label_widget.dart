// import 'package:flutter/material.dart';
//
// class InlineLabelWidget extends StatelessWidget {
//   final String text;
//   final IconData icon;
//   final double iconSize;
//   final TextStyle textStyle;
//
//   const InlineLabelWidget({
//     super.key,
//     required this.text,
//     this.icon = Icons.directions_walk,
//     this.iconSize = 16.0,
//     this.textStyle = const TextStyle(
//       fontSize: 12,
//       color: Colors.black,
//       fontWeight: FontWeight.bold,
//     ),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           size: iconSize,
//           color: textStyle.color,
//         ),
//         const SizedBox(width: 4.0),
//         Text(
//           text,
//           style: textStyle,
//         ),
//       ],
//     );
//   }
// }
