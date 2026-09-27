import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Reusable top app bar adhering to Spendly's clean visual identity.
/// Respects active theme's background and typography automatically.
class SpendlyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpendlyAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.backgroundColor,
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(
        subtitle != null ? 72.0 : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.appBarTheme.backgroundColor;
    final titleStyle = theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge!;
    final subtitleStyle = theme.textTheme.bodySmall!;

    return AppBar(
      backgroundColor: effectiveBgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: titleWidget ??
          (subtitle == null
              ? Text(
                  title,
                  style: titleStyle,
                )
              : Column(
                  crossAxisAlignment: centerTitle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: titleStyle,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      subtitle!,
                      style: subtitleStyle,
                    ),
                  ],
                )),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: AppDimensions.spacingSm),
            ]
          : null,
    );
  }
}
