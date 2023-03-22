# Insigno

Flutter frontend for Insigno.

## Dependency injection

Quando si aggiungono o spostano file di Dependency Injection (ad esempio, quelli contenenti `@singleton`, `@lazySingleton`, `@injectable` o `@module`), bisogna rigenerare il file di setup `lib/di/setup.config.dart` ([fonte](https://github.com/Milad-Akarie/injectable#run-the-generator)).
```bash
# rigenera i file una volta sola
flutter pub run build_runner build

# rigenera i file ad ogni modifica, finche' e' in esecuzione
flutter pub run build_runner watch
```

## Naming

TODO


## Flutter getting started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
