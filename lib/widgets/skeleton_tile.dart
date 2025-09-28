import 'package:flutter/material.dart';

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Container(height: 14, color: Colors.black12),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Container(height: 12, color: Colors.black12),
      ),
    );
  }
}
