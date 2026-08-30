import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';

/// Placeholder — the "Sign up here." link on the login page needs a real
/// destination, but no register flow (usecase/bloc/API) exists yet in this
/// boilerplate. Replace this with your own registration form.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                const Icon(Icons.person_add_alt_1_outlined,
                    size: 56, color: kMainSecondary),
                const SizedBox(height: 24),
                Text('Register', textAlign: TextAlign.center, style: genStyle20Bold),
                const SizedBox(height: 4),
                Text(
                  'This screen is a placeholder — build your registration flow here.',
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
