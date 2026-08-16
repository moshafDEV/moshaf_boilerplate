import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/presentation/components/button.dart';

import 'app_path.dart';

/// Visible fallback for a route that couldn't be built, instead of Flutter's unhandled-cast grey box.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, required this.title, this.detail});

  final String title;
  final String? detail;

  /// Rebuilds from splash (keeps DI/services up) rather than restarting — used when there's nothing to pop back to.
  void _restart(BuildContext context) {
    context.go(Paths.splash);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kMainPrimary,
                  size: 16,
                ),
              )
            : null,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: kMainDanger),
                const SizedBox(height: 24),
                Text(title, textAlign: TextAlign.center, style: genStyle20Bold),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail!,
                    textAlign: TextAlign.center,
                    style: genStyle14Regular.copyWith(color: kMainSecondary),
                  ),
                ],
                const SizedBox(height: 32),
                if (canPop)
                  PrimaryButton(
                    text: 'Go back',
                    onPressed: () => context.pop(),
                  )
                else
                  PrimaryButton(
                    text: 'Restart app',
                    onPressed: () => _restart(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
