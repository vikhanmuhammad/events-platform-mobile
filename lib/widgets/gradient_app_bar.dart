import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleTrailing;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  const GradientAppBar({
    super.key,
    required this.title,
    this.titleTrailing,
    this.actions,
    this.bottom,
    this.leading,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (titleTrailing != null) titleTrailing!,
          ],
        ),
        leading: leading,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
        bottom: bottom,
      ),
    );
  }
}
