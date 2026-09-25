import 'package:flutter/material.dart';

class UserGroupStatusIndicator extends StatelessWidget {
  const UserGroupStatusIndicator({
    super.key,
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
  });

  final bool value;
  final String trueLabel;
  final String falseLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 18,
          color: value ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(value ? trueLabel : falseLabel),
      ],
    );
  }
}
