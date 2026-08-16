import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/assets.gen.dart';
import 'package:ProjectName/core/constants/colors.dart';

class AvatarProfile extends StatefulWidget {
  final String? imageUrl;
  final double? size;
  final VoidCallback? onTap;
  final String? presenceState;
  final bool showBorder;

  const AvatarProfile({
    super.key,
    this.imageUrl,
    this.size,
    this.onTap,
    this.presenceState,
    this.showBorder = true,
  });

  @override
  State<AvatarProfile> createState() => _AvatarProfileState();
}

class _AvatarProfileState extends State<AvatarProfile> {
  bool hasError = false;

  @override
  void didUpdateWidget(AvatarProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Without this the first failure (typically the empty url of the initial
    // profile state) latches forever and the real avatar never appears.
    if (oldWidget.imageUrl != widget.imageUrl) {
      hasError = false;
    }
  }

  Color _indicatorColor(String state) {
    switch (state) {
      case 'online':
        return kMainSuccess;
      case 'idle':
        return kMainWarning;
      default:
        return kMainGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.size ?? 28;
    final scale = r / 28;
    final dotSize = (10 * scale).clamp(9.0, 12.0);
    final dotOffsetBottom = (3 * scale).clamp(1.5, 4.0);
    final dotOffsetRight = (2 * scale).clamp(0.8, 3.0);
    final dotBorder = (1 * scale).clamp(0.8, 1.5);
    final borderWidth = widget.showBorder ? (2 * scale).clamp(1.2, 2.5) : 0.0;

    final content = Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderWidth > 0
                ? Border.all(color: kMainWhite, width: borderWidth)
                : null,
          ),
          child: (hasError || (widget.imageUrl ?? '').isEmpty)
              ? CircleAvatar(
                  radius: r,
                  backgroundImage: AssetImage(Assets.images.imgProfileDefault),
                )
              : CircleAvatar(
                  radius: r,
                  backgroundImage: NetworkImage(widget.imageUrl!),
                  backgroundColor: kMainWhite,
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fires during paint, so defer: setState here would be a
                    // markNeedsBuild during paint.
                    if (hasError) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => hasError = true);
                    });
                  },
                ),
        ),
        if (widget.presenceState != null)
          Positioned(
            bottom: dotOffsetBottom,
            right: dotOffsetRight,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _indicatorColor(widget.presenceState!),
                border: Border.all(color: kMainWhite, width: dotBorder),
              ),
            ),
          ),
      ],
    );

    if (widget.onTap == null) return content;
    return GestureDetector(onTap: widget.onTap, child: content);
  }
}
