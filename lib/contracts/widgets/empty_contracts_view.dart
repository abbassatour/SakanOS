// lib/contracts/widgets/empty_contracts_view.dart

import 'package:flutter/material.dart';

class EmptyContractsView extends StatelessWidget {
  const EmptyContractsView({
    required this.message,
    required this.icon,
    required this.iconColor,
    super.key,
  });

  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
