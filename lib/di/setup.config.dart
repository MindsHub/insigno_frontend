// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:http/http.dart' as _i3;
import 'package:injectable/injectable.dart' as _i2;
import 'package:insigno_frontend/networking/authentication.dart' as _i8;
import 'package:insigno_frontend/networking/backend.dart' as _i9;
import 'package:insigno_frontend/networking/client.dart' as _i4;
import 'package:insigno_frontend/networking/server_host_handler.dart' as _i7;
import 'package:insigno_frontend/pref/preferences.dart' as _i12;
import 'package:insigno_frontend/provider/auth_user_provider.dart' as _i11;
import 'package:insigno_frontend/provider/location_provider.dart' as _i5;
import 'package:insigno_frontend/provider/verify_time_provider.dart' as _i10;
import 'package:shared_preferences/shared_preferences.dart' as _i6;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final clientModule = _$ClientModule();
    final preferencesModule = _$PreferencesModule();
    gh.lazySingleton<_i3.Client>(
      () => clientModule.httpClient,
      dispose: _i4.disposeClient,
    );
    gh.lazySingleton<_i5.LocationProvider>(
      () => _i5.LocationProvider(),
      dispose: (i) => i.dispose(),
    );
    await gh.factoryAsync<_i6.SharedPreferences>(
      () => preferencesModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i7.ServerHostHandler>(
        () => _i7.ServerHostHandler(gh<_i6.SharedPreferences>()));
    gh.lazySingleton<_i8.Authentication>(() => _i8.Authentication(
          gh<_i3.Client>(),
          gh<_i6.SharedPreferences>(),
          gh<_i7.ServerHostHandler>(),
        ));
    gh.lazySingleton<_i9.Backend>(() => _i9.Backend(
          gh<_i3.Client>(),
          gh<_i8.Authentication>(),
          gh<_i7.ServerHostHandler>(),
        ));
    gh.lazySingleton<_i10.VerifyTimeProvider>(
      () => _i10.VerifyTimeProvider(
        gh<_i9.Backend>(),
        gh<_i8.Authentication>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i11.AuthUserProvider>(
      () => _i11.AuthUserProvider(gh<_i9.Backend>()),
      dispose: (i) => i.dispose(),
    );
    return this;
  }
}

class _$ClientModule extends _i4.ClientModule {}

class _$PreferencesModule extends _i12.PreferencesModule {}
