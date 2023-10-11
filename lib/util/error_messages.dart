import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/provider/location_info.dart';

enum ErrorMessage {
  loginRequired,
  grantLocationPermission,
  enableLocationServices,
  locationIsLoading,
  addImage,
  selectMarkerType,
  tooFarToResolve,
  oldVersion;

  String toLocalizedString(AppLocalizations l10n) {
    switch (this) {
      case ErrorMessage.loginRequired: return l10n.loginRequired;
      case ErrorMessage.grantLocationPermission: return l10n.grantLocationPermission;
      case ErrorMessage.enableLocationServices: return l10n.enableLocationServices;
      case ErrorMessage.locationIsLoading: return l10n.locationIsLoading;
      case ErrorMessage.addImage: return l10n.addImage;
      case ErrorMessage.selectMarkerType: return l10n.selectMarkerType;
      case ErrorMessage.tooFarToResolve: return l10n.tooFarToResolve;
      case ErrorMessage.oldVersion: return l10n.oldVersion;
    }
  }
}

ErrorMessage? getErrorMessage(bool? isLoggedIn, LocationInfo? position,
    {ErrorMessage? Function()? whilePositionLoading,
      ErrorMessage? Function()? afterPositionLoaded}) {
  if (!(isLoggedIn ?? false)) {
    return ErrorMessage.loginRequired;
  } else if (position?.permissionGranted == false) {
    return ErrorMessage.grantLocationPermission;
  } else if (position?.servicesEnabled == false) {
    return ErrorMessage.enableLocationServices;
  }

  if (whilePositionLoading != null) {
    final res = whilePositionLoading();
    if (res != null) {
      return res;
    }
  }

  if (position?.position == null) {
    return ErrorMessage.locationIsLoading;
  }

  if (afterPositionLoaded != null) {
    return afterPositionLoaded();
  } else {
    return null;
  }
}
