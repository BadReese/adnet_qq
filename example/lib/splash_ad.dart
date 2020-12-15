import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adnet_qq/adnet_qq.dart';

import 'config.dart';

class SplashWidget extends StatefulWidget {
  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  bool adLoaded = false;
  @override
  void initState() {
    super.initState();
    // Initialize plugin and show splash here.
    AdnetQqPlugin.config(appId: config['appId'], requestReadPhoneState: 0, requestAccessFineLocation: 0, adChannel: 1).then((_) => SplashAd(config['splashPosId'], backgroundImage: config['splashBackgroundImage'], adEventCallback: (event, _) {
      if(event == SplashAdEvent.onAdLoaded) {
        adLoaded = true;
        return;
      }
      if(event == SplashAdEvent.onAdClosed || event == SplashAdEvent.onAdDismiss || event == SplashAdEvent.onNoAd) {
        if(this.mounted) {
          // Go to home page when splash is finished.
          Navigator.of(context, nullOk: true)?.pushReplacementNamed('/');
        }
      }
    }).showAd());
    Future.delayed(Duration(seconds: 5), () {
      // If ad is not loaded in 5 seconds, give up this chance.
      if(!adLoaded && this.mounted) {
        Navigator.of(context, nullOk: true)?.pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.amber,
        child: Center(
          child: Text(
            'SPLASH',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
