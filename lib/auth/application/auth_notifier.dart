import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_repo_app/auth/domain/auth_failure.dart';
import 'package:github_repo_app/auth/infrastructure/github_authenticator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'auth_notifier.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.failure(AuthFailure failure) = _Failure;
}

typedef AuthUrlCallback = Future<Uri> Function(Uri authorizationUrl);

class AuthNotifier extends StateNotifier<AuthState> {
  final GithubAuthenticator _authenticator;
  AuthNotifier(this._authenticator) : super(const AuthState.initial());

  Future<void> checkAndUpdateAuthStatus() async {
    state = (await _authenticator.isSignedIn())
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated();
  }

  Future<void> signIn(AuthUrlCallback authorizationUrlCallback) async {
    final grant = _authenticator.createGrant();
    final redirectUrl = await authorizationUrlCallback(
        _authenticator.getAuthorizationUrl(grant));
    final failureOrSuccess = await _authenticator.handleAuthorizationResponse(
        grant, redirectUrl.queryParameters);
    state = failureOrSuccess.fold(
      (failure) => AuthState.failure(failure),
      (r) => const AuthState.authenticated(),
    );
    grant.close();
  }

  Future<void> signOut() async {
    final failureOrSuccess = await _authenticator.signOut();
    state = failureOrSuccess.fold(
      (failure) => AuthState.failure(failure),
      (r) => const AuthState.unauthenticated(),
    );
  }
}
