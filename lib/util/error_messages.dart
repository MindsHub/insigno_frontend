import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/page/map/location_info.dart';

String? getErrorMessage(AppLocalizations l10n, bool? isLoggedIn, LocationInfo? position,
    {String? Function()? whilePositionLoading,
    bool includeErrorForPositionLoading = true,
    String? Function()? afterPositionLoaded}) {
  if (!(isLoggedIn ?? false)) {
    return l10n.loginRequired;
  } else if (position?.permissionGranted == false) {
    return l10n.grantLocationPermission;
  } else if (position?.servicesEnabled == false) {
    return l10n.enableLocationServices;
  }

  if (whilePositionLoading != null) {
    final res = whilePositionLoading();
    if (res != null) {
      return res;
    }
  }

  if (includeErrorForPositionLoading && position?.position == null) {
    return l10n.locationIsLoading;
  }

  if (afterPositionLoaded != null) {
    return afterPositionLoaded();
  } else {
    return null;
  }
}
