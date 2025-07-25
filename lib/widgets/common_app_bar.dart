import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;
  final Widget? leading;
  final String? heroTag;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor = Colors.white,
    this.elevation = 0.0,
    this.leading,
    this.heroTag,
  });

  // Determine if the background color is dark to adjust text/icon color
  bool _isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    // Choose text/icon color based on background brightness
    final foregroundColor = _isDarkColor(backgroundColor) ? Colors.white : Colors.black;

    final appBar = AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: foregroundColor),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: foregroundColor,
        ),
      ),
      actions: actions,
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: Material(color: Colors.transparent, child: appBar));
    }

    return appBar;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}