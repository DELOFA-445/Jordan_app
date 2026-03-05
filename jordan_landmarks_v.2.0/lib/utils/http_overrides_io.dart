import 'dart:io';

class ArchiveHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (host.contains('archive.org') == true) {
        return true;
      } else {
        return false;
      }
    };
    return client;
  }
}

void setupHttpOverrides() {
  HttpOverrides.global = ArchiveHttpOverrides();
}
