import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ProjectName/core/constants/colors.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final bool hasGradient;
  final List<Color>? gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.width,
    this.height = 56,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.hasGradient = false,
    this.gradientColors,
    this.borderRadius = 8,
    this.padding,
    this.elevation = 8,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (widget.enabled && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = widget.backgroundColor ?? kMainGreen;
    final defaultTextColor = widget.textColor ?? Colors.white;
    final buttonWidth = widget.width ?? double.infinity;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: buttonWidth,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.hasGradient
                    ? LinearGradient(
                        colors:
                            widget.gradientColors ??
                            [kMainGreen, kMainGreenDark],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: widget.hasGradient ? null : defaultBackgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color:
                              (widget.hasGradient
                                      ? (widget.gradientColors?.first ??
                                            kMainGreen)
                                      : defaultBackgroundColor)
                                  .withAlpha(40),
                          blurRadius: widget.elevation ?? 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onTap: _handleTap,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Padding(
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  defaultTextColor,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: defaultTextColor,
                                    size: widget.fontSize! + 2,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(widget.text, style: widget.textStyle),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
