# Insigno

Flutter frontend for Insigno.

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/org.mindshub.insigno/)
[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=org.mindshub.insigno)

Or get the latest APK from the [Releases Section](https://github.com/MindsHub/insigno_frontend/releases/latest).

## Dependency injection

Quando si aggiungono o spostano file di Dependency Injection (ad esempio, quelli contenenti `@singleton`, `@lazySingleton`, `@injectable` o `@module`), bisogna rigenerare il file di setup `lib/di/setup.config.dart` ([fonte](https://github.com/Milad-Akarie/injectable#run-the-generator)).
```bash
# rigenera i file una volta sola
flutter pub run build_runner build

# rigenera i file ad ogni modifica, finche' e' in esecuzione
flutter pub run build_runner watch
```

## TODOs

- [x] Optimize performance of map when there are many markers to display
- [ ] Improve error handling

## Flutter getting started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Screenshots

Cose di cui assicurarsi:
- alternare tema chiaro e scuro
- ripetere in italiano e in inglese
- togliere tutti i metadati con `mogrify -strip ./*.png`
- comprimere le immagini con `optipng *.png`

Descrizioni degli screenshot:
- 0.png - SCURO - schermata principale con mappa e pillola decente
- 1.png - CHIARO - menu che permette di filtrare i materiali
- 2.png - SCURO - schermata di segnalazione nuovo marker
- 3.png - CHIARO - marker screen con un marker diverso da quello appena riportato
- 4.png - SCURO - profilo non da admin con "suggerisci pillola" aperto
- 5.png - CHIARO - revisione immagini (non da admin ma normale)
- 6.png - SCURO - classifica non globale ma entro una distanza così i punteggi sono solo quelli dei marker