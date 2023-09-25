import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// taken from the HTML5 validation spec, except for the + at the end which used to be a *
final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)+$");
final _nameRegex = RegExp(r'^[a-zA-Z0-9 _]*$');
final _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).*$');

String? emailValidator(AppLocalizations l10n, String? value) {
  final v = value?.trim() ?? "";
  if (v.isEmpty) {
    return l10n.insertEmail;
  } else if (!_emailRegex.hasMatch(v)) {
    return l10n.insertValidEmail;
  } else {
    return null;
  }
}

String? nameValidator(AppLocalizations l10n, String? value) {
  final v = value?.trim() ?? "";
  if (v.isEmpty) {
    return l10n.insertName;
  } else if (v.length < 3 || v.length > 20) {
    return l10n.invalidNameLength;
  } else if (!_nameRegex.hasMatch(v)) {
    return l10n.invalidNameCharacters;
  } else {
    return null;
  }
}

String? passwordValidator(AppLocalizations l10n, String? value) {
  final v = value ?? "";
  if (v.isEmpty) {
    return l10n.insertPassword;
  } else if (v.length < 8) {
    return l10n.invalidPasswordLength;
  } else if (!_passwordRegex.hasMatch(v)) {
    return l10n.invalidPasswordCharacters;
  } else {
    return null;
  }
}

String? repeatPasswordValidator(AppLocalizations l10n, String? value, String? otherValue) {
  if (value != otherValue) {
    return l10n.passwordsNotMatch;
  } else {
    return null;
  }
}
