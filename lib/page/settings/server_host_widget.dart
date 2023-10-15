import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:insigno_frontend/networking/error.dart';
import 'package:insigno_frontend/networking/server_host_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ServerHostWidget extends StatefulWidget with GetItStatefulWidgetMixin {
  ServerHostWidget({Key? key}) : super(key: key);

  @override
  State<ServerHostWidget> createState() => _ServerHostWidgetState();
}

class _ServerHostWidgetState extends State<ServerHostWidget>
    with GetItStateMixin<ServerHostWidget> {
  TextEditingController? _controller;

  bool editing = false;
  bool loading = false;
  bool uriError = false;
  bool serverError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: get<ServerHostHandler>().getUri("").toString());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final currentUriString = watchStream((ServerHostHandler s) => s.getUriStringStream(),
                get<ServerHostHandler>().getUri("").toString())
            .data ??
        ServerHostHandler.getDefaultUriString();

    final normalizedInput = getNormalizedInput();

    return Column(
      children: [
        TextField(
            onChanged: (v) {
              setState(() {});
            },
            controller: _controller,
            enabled: editing,
            autofillHints: const [AutofillHints.url],
            decoration: InputDecoration(
              labelText: l10n.hostServer,
              errorText: uriError
                  ? l10n.insertValidUrl
                  : serverError
                      ? l10n.invalidHostServer
                      : null,
              hintText: ServerHostHandler.getDefaultUriString(),
            ),
            onSubmitted: (v) async {
              await useUriString();
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n.hostServerDescription,
            style: theme.textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CircularProgressIndicator(),
          )
        else if (editing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: normalizedInput == "" ||
                        normalizedInput == ServerHostHandler.getDefaultUriString() ||
                        normalizedInput == currentUriString
                    ? null
                    : useUriString,
                child: Text(l10n.use),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller?.text = get<ServerHostHandler>().getUri("").toString();
                    editing = false;
                    uriError = false;
                    serverError = false;
                    loading = false;
                  });
                },
                child: Text(l10n.cancel),
              ),
            ],
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    editing = true;
                  });
                },
                child: Text(l10n.edit),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                  onPressed: currentUriString == ServerHostHandler.getDefaultUriString()
                      ? null
                      : resetUriString,
                  child: Text(l10n.reset)),
            ],
          ),
      ],
    );
  }

  String getNormalizedInput() {
    final text = _controller?.text;
    if (text == null) {
      return "";
    } else if (text.contains("://")) {
      return text;
    } else {
      return "https://$text";
    }
  }

  void resetUriString() async {
    await get<ServerHostHandler>().resetSchemeHost();
    _controller?.text = ServerHostHandler.getDefaultUriString();
    setState(() {
      uriError = false;
      serverError = false;
      loading = false;
    });
  }

  Future<void> useUriString() async {
    setState(() {
      uriError = false;
      serverError = false;
      loading = true;
    });

    final Uri uri;
    try {
      uri = Uri.parse(getNormalizedInput());
    } on FormatException catch (_) {
      setState(() {
        uriError = true;
        serverError = false;
        loading = false;
      });
      return;
    }

    if (!uri.hasScheme || uri.host.isEmpty || !uri.hasEmptyPath || uri.hasQuery) {
      setState(() {
        uriError = true;
        serverError = false;
        loading = false;
      });
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    try {
      await get<http.Client>() //
          .head(Uri(
            scheme: uri.scheme,
            host: uri.host,
            port: uri.port,
            path: "/compatibile",
            queryParameters: {"version_str": packageInfo.version},
          ))
          .timeout(const Duration(seconds: 3))
          .throwErrors();
    } on FormatException catch (_) {
      setState(() {
        uriError = true;
        serverError = false;
        loading = false;
      });
      return;
    } catch (e) {
      setState(() {
        uriError = false;
        serverError = true;
        loading = false;
      });
      return;
    }

    get<ServerHostHandler>().setSchemeHost(uri.scheme, uri.host, uri.hasPort ? uri.port : null);
    _controller?.text = get<ServerHostHandler>().getUri("").toString();
    setState(() {
      editing = false;
      uriError = false;
      serverError = false;
      loading = false;
    });
  }
}
