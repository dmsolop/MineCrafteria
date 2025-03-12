import 'package:url_launcher/url_launcher.dart';

class OpenURL {
  static void openURL(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url)) {
      // throw Exception('Could not launch $_url');
    }
  }
}