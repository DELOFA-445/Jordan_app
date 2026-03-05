import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WikipediaSourceButton extends StatelessWidget {
  String url;
  String label;

  WikipediaSourceButton({
    super.key,
    required this.url,
    required this.label,
  });

  launchMyUrl(BuildContext context) async {
    var uri = Uri.parse(url);
    try {
      var check = await canLaunchUrl(uri);
      if (check == true) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch ' + url),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            launchMyUrl(context);
          },
          icon: Icon(Icons.language, size: 20),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Colors.brown.shade300, width: 1.5),
            foregroundColor: Colors.brown.shade800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
