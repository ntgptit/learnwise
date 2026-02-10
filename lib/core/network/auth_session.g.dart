// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authSessionManager)
const authSessionManagerProvider = AuthSessionManagerProvider._();

final class AuthSessionManagerProvider
    extends
        $FunctionalProvider<
          AuthSessionManager,
          AuthSessionManager,
          AuthSessionManager
        >
    with $Provider<AuthSessionManager> {
  const AuthSessionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionManagerHash();

  @$internal
  @override
  $ProviderElement<AuthSessionManager> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthSessionManager create(Ref ref) {
    return authSessionManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSessionManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSessionManager>(value),
    );
  }
}

String _$authSessionManagerHash() =>
    r'4ad92c794476b3c14cd3110fcb4bc7a00b1d189e';
