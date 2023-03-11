import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:github_repo_app/core/shared/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:github_repo_app/auth/application/auth_notifier.dart';
import 'package:github_repo_app/auth/shared/providers.dart';
import 'package:github_repo_app/core/presentation/routes/app_router.gr.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final initializationProvider = FutureProvider<Unit>((ref) async {
  await ref.read(sembaseProvider).init();
  // ref.read(dioProvider)
  //   ..options = BaseOptions(
  //     headers: {
  //       'Accept': 'application/vnd.github.v3.html+json',
  //     },
  //     validateStatus: (status) =>
  //         status != null && status >= 200 && status < 400,
  //   )
  //   ..interceptors.add(ref.read(oAuth2InterceptorProvider));
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthStatus();
  return unit;
});

class AppWidget extends ConsumerWidget {
  final appRouter = AppRouter();

  AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      initializationProvider,
      (previous, next) => Void,
    );
    ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        next.maybeMap(
            orElse: () {},
            authenticated: (_) {
              appRouter.pushAndPopUntil(const StarredReposRoute(),
                  predicate: (route) => false);
            },
            unauthenticated: (_) {
              appRouter.pushAndPopUntil(const SignInRoute(),
                  predicate: (route) => false);
            });
      },
    );
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp.router(
          title: 'Github Repo',
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
        );
      },
    );
  }
}
