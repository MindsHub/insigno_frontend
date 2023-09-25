import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:insigno_frontend/page/user/change_password_widget.dart';

class ChangePasswordPage extends StatelessWidget {
  static const routeName = "/changePasswordPage";

  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.changePassword),
      ),
      body: Center(
        child: ChangePasswordWidget((changeRequestSent) {
          Navigator.pop(context, changeRequestSent);
        }),
      ),
    );
  }
}
