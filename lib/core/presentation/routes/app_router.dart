import 'package:auto_route/annotations.dart';
import 'package:github_repo_app/auth/presentation/sign_in_page.dart';
import 'package:github_repo_app/presentation/starred_repos_page.dart';
import 'package:github_repo_app/splash/presentation/splash_page.dart';

@MaterialAutoRouter(
  routes: [
    MaterialRoute(page: SplashPage, initial: true),
    MaterialRoute(page: SignInPage, path: '/sign_in'),
    MaterialRoute(page: StarredReposPage, path: '/Starred')
  ],
  replaceInRouteName: 'Page,Route',
)
class $AppRouter {}
