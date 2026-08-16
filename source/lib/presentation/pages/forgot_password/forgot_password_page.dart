import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';

/// Placeholder — the "Lupa password?" link on the login page needs a real
/// destination, but no password-reset flow (usecase/bloc/API) exists yet in
/// this boilerplate. Replace this with your own implementation.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kMainPrimary,
                  size: 16,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_reset_outlined,
                    size: 56, color: kMainSecondary),
                const SizedBox(height: 24),
                Text('Forgot Password',
                    textAlign: TextAlign.center, style: genStyle20Bold),
                const SizedBox(height: 4),
                Text(
                  'This screen is a placeholder — build your password-reset flow here.',
                  textAlign: TextAlign.center,
                  style: genStyle14Regular.copyWith(color: kMainSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
