import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Auto-scrolling horizontal marquee for arbitrary widgets — takes a plain
/// [children] list, no domain coupling.
class WidgetMarquee extends StatefulWidget {
  const WidgetMarquee({
    super.key,
    required this.children,
    this.spacing = 16,
    this.velocity = 60,
    this.blankSpace = 40,
    this.pauseAfterRound = Duration.zero,
    this.reverse = false,
    this.remeasureInterval = const Duration(milliseconds: 300),
  });

  final List<Widget> children;
  final double spacing;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;
  final bool reverse;
  final Duration remeasureInterval;

  @override
  State<WidgetMarquee> createState() => _WidgetMarqueeState();
}

class _WidgetMarqueeState extends State<WidgetMarquee> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentKey = GlobalKey();

  StreamSubscription<int>? _measureSubscription;

  double _contentWidth = 0;
  double _viewportWidth = 0;

  bool _isRunning = false;
  int _loopToken = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndRestart(resetPosition: true);
      _startMeasureListener();
    });
  }

  @override
  void didUpdateWidget(covariant WidgetMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);

    final childrenChanged = !listEquals(oldWidget.children, widget.children);

    final needRestart = childrenChanged ||
        oldWidget.spacing != widget.spacing ||
        oldWidget.velocity != widget.velocity ||
        oldWidget.blankSpace != widget.blankSpace ||
        oldWidget.reverse != widget.reverse;

    final needResubscribe =
        oldWidget.remeasureInterval != widget.remeasureInterval;

    if (needResubscribe) {
      _startMeasureListener();
    }

    if (needRestart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureAndRestart(resetPosition: true);
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();

    // Called on hot reload.
    _stopCurrentLoop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureAndRestart(resetPosition: true);
    });
  }

  void _startMeasureListener() {
    _measureSubscription?.cancel();

    _measureSubscription =
        Stream.periodic(widget.remeasureInterval, (count) => count).listen((_) {
      if (!mounted) return;
      _measureAndRestart();
    });
  }

  void _stopCurrentLoop() {
    _loopToken++;
    _isRunning = false;
  }

  void _measureAndRestart({bool resetPosition = false}) {
    if (!mounted) return;

    final contentContext = _contentKey.currentContext;
    final contentBox = contentContext?.findRenderObject() as RenderBox?;
    final viewportBox = context.findRenderObject() as RenderBox?;

    if (contentBox == null || viewportBox == null) return;

    final newContentWidth = contentBox.size.width;
    final newViewportWidth = viewportBox.size.width;

    final sizeChanged =
        newContentWidth != _contentWidth || newViewportWidth != _viewportWidth;

    _contentWidth = newContentWidth;
    _viewportWidth = newViewportWidth;

    if (sizeChanged || resetPosition) {
      _restartMarquee();
    }
  }

  void _restartMarquee() {
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _restartMarquee();
      });
      return;
    }

    _stopCurrentLoop();

    if (widget.children.isEmpty || _contentWidth <= _viewportWidth) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      return;
    }

    final start = widget.reverse ? (_contentWidth + widget.blankSpace) : 0.0;

    try {
      _scrollController.jumpTo(start);
    } catch (_) {
      return;
    }

    _startLoop();
  }

  Future<void> _startLoop() async {
    if (!mounted || !_scrollController.hasClients) return;
    if (_isRunning) return;

    _isRunning = true;
    final token = _loopToken;

    while (mounted &&
        _scrollController.hasClients &&
        _isRunning &&
        token == _loopToken) {
      final start = widget.reverse ? (_contentWidth + widget.blankSpace) : 0.0;
      final end = widget.reverse ? 0.0 : (_contentWidth + widget.blankSpace);

      final distance = (end - start).abs();

      if (distance <= 0 || widget.velocity <= 0) {
        break;
      }

      final duration =
          Duration(milliseconds: ((distance / widget.velocity) * 1000).round());

      try {
        await _scrollController.animateTo(end,
            duration: duration, curve: Curves.linear);
      } catch (_) {
        break;
      }

      if (!mounted ||
          !_scrollController.hasClients ||
          !_isRunning ||
          token != _loopToken) {
        break;
      }

      if (widget.pauseAfterRound > Duration.zero) {
        await Future.delayed(widget.pauseAfterRound);
      }

      if (!mounted ||
          !_scrollController.hasClients ||
          !_isRunning ||
          token != _loopToken) {
        break;
      }

      try {
        _scrollController.jumpTo(start);
      } catch (_) {
        break;
      }
    }

    if (token == _loopToken) {
      _isRunning = false;
    }
  }

  List<Widget> _buildChildren() {
    final items = <Widget>[];

    for (var i = 0; i < widget.children.length; i++) {
      items.add(widget.children[i]);

      if (i != widget.children.length - 1) {
        items.add(SizedBox(width: widget.spacing));
      }
    }

    return items;
  }

  @override
  void dispose() {
    _measureSubscription?.cancel();
    _stopCurrentLoop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          key: _contentKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._buildChildren(),
            SizedBox(width: widget.blankSpace),
            ..._buildChildren(),
          ],
        ),
      ),
    );
  }
}
