import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/developer_tools/developer_menu_page.dart';
import 'package:ProjectName/core/developer_tools/developer_navigation.dart';

/// Floating, draggable trigger for [DeveloperMenuPage]. Position is kept in
/// this widget's own State — it persists for as long as the app keeps
/// running (per spec: "selama aplikasi berjalan"), not across restarts, so
/// no persistence layer is involved.
class DraggableDebugButton extends StatefulWidget {
  const DraggableDebugButton({super.key});

  @override
  State<DraggableDebugButton> createState() => _DraggableDebugButtonState();
}

class _DraggableDebugButtonState extends State<DraggableDebugButton> {
  static const _size = 56.0;
  static const _margin = 8.0;

  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    final maxX = screenSize.width - _size - _margin;
    final maxY = screenSize.height - _size - _margin - safePadding.bottom;
    final minY = safePadding.top + _margin;

    // Default corner: bottom-LEFT, not bottom-right — the flavor banner
    // ribbon (FlavorBanner, BannerLocation.bottomEnd) also lives in the
    // bottom-right corner, and the two visually collided there. Still
    // freely draggable anywhere afterward.
    _position ??= Offset(_margin, maxY);

    final clamped = Offset(
      _position!.dx.clamp(_margin, maxX < _margin ? _margin : maxX),
      _position!.dy.clamp(minY, maxY < minY ? minY : maxY),
    );

    return Positioned(
      left: clamped.dx,
      top: clamped.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() {
          _position = clamped + details.delta;
        }),
        onTap: () => pushDeveloperPage(const DeveloperMenuPage()),
        child: Container(
          width: _size,
          height: _size,
          decoration: const BoxDecoration(
            color: kMainDanger,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.bug_report, color: kMainWhite),
        ),
      ),
    );
  }
}
