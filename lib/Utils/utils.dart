import 'package:url_launcher/url_launcher.dart';

class Utils{

  static Future<void> dialPhoneNumber(String phoneNumber) async{
    final call = Uri.parse('tel:+20 ${phoneNumber}');
    if (await canLaunchUrl(call)) {
      launchUrl(call);
    } else {
      throw 'Could not launch $call';
    }
  }

}