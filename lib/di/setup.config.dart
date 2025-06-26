// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:insigno_frontend/networking/authentication.dart' as _i1040;
import 'package:insigno_frontend/networking/backend.dart' as _i241;
import 'package:insigno_frontend/networking/client.dart' as _i509;
import 'package:insigno_frontend/networking/server_host_handler.dart' as _i568;
import 'package:insigno_frontend/pref/preferences.dart' as _i414;
import 'package:insigno_frontend/provider/auth_user_provider.dart' as _i968;
import 'package:insigno_frontend/provider/location_provider.dart' as _i674;
import 'package:insigno_frontend/provider/verify_time_provider.dart' as _i703;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final preferencesModule = _$PreferencesModule();
    final clientModule = _$ClientModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => preferencesModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i519.Client>(
      () => clientModule.httpClient,
      dispose: _i509.disposeClient,
    );
    gh.lazySingleton<_i674.LocationProvider>(
      () => _i674.LocationProvider(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i568.ServerHostHandler>(
        () => _i568.ServerHostHandler(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i1040.Authentication>(() => _i1040.Authentication(
          gh<_i519.Client>(),
          gh<_i460.SharedPreferences>(),
          gh<_i568.ServerHostHandler>(),
        ));
    gh.lazySingleton<_i241.Backend>(() => _i241.Backend(
          gh<_i519.Client>(),
          gh<_i1040.Authentication>(),
          gh<_i568.ServerHostHandler>(),
        ));
    gh.lazySingleton<_i968.AuthUserProvider>(
      () => _i968.AuthUserProvider(gh<_i241.Backend>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i703.VerifyTimeProvider>(
      () => _i703.VerifyTimeProvider(
        gh<_i241.Backend>(),
        gh<_i1040.Authentication>(),
      ),
      dispose: (i) => i.dispose(),
    );
    return this;
  }
}

class _$PreferencesModule extends _i414.PreferencesModule {}

class _$ClientModule extends _i509.ClientModule {}
