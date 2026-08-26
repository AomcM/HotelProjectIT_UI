import 'package:flutter/material.dart';

/// Branded AppBar used across every screen in the app.
/// Shows the Pickalbatros bird mark next to the screen title.
///
/// Usage (replace your existing `appBar: AppBar(...)` with):
///   appBar: HotelAppBar(
///     title: "Hotel IT",
///     actions: [
///       IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
///     ],
///   ),
class HotelAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const HotelAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      centerTitle: centerTitle,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/bird_logo.png',
            height: 10,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Small standalone bird mark, for places that aren't an AppBar
/// (e.g. splash screen, empty states, drawer header).
/// Usage: const BirdMark(size: 40)
class BirdMark extends StatelessWidget {
  final double size;
  const BirdMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/bird_logo.png',
      height: size,
      fit: BoxFit.contain,
    );
  }
}