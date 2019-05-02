import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

enum UnifiedBannerAdEvent {
  onNoAd,
  onAdReceived,
  onAdExposure,
  onAdClosed,
  onAdClicked,
  onAdLeftApplication,
  onAdOpenOverlay,
  onAdCloseOverlay,
}

typedef UnifiedBannerAdEventCallback = Function(UnifiedBannerAdEvent event, dynamic arguments);

class UnifiedBannerAd extends StatefulWidget {
  /// 宽高比
  static final double ratio = 6.4;

  final String posId;

  final UnifiedBannerAdEventCallback adEventCallback;

  final bool refreshOnCreate;

  UnifiedBannerAd(this.posId, {Key key, this.adEventCallback, this.refreshOnCreate}) : super(key: key);

  @override
  UnifiedBannerAdState createState() => UnifiedBannerAdState();
}

class UnifiedBannerAdState extends State<UnifiedBannerAd> {
  MethodChannel _methodChannel;
  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: '$PLUGIN_ID/unified_banner',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posId': widget.posId},
      creationParamsCodec: StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    this._methodChannel = MethodChannel('$PLUGIN_ID/unified_banner_$id');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
    if(this.widget.refreshOnCreate == true) {
      this.refreshAd();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(widget.adEventCallback != null) {
      UnifiedBannerAdEvent event;
      switch(call.method) {
        case 'onNoAd':
          event = UnifiedBannerAdEvent.onNoAd;
          break;
        case 'onAdReceived':
          event = UnifiedBannerAdEvent.onAdReceived;
          break;
        case 'onAdExposure':
          event = UnifiedBannerAdEvent.onAdExposure;
          break;
        case 'onAdClosed':
          event = UnifiedBannerAdEvent.onAdClosed;
          break;
        case 'onAdClicked':
          event = UnifiedBannerAdEvent.onAdClicked;
          break;
        case 'onAdLeftApplication':
          event = UnifiedBannerAdEvent.onAdLeftApplication;
          break;
        case 'onAdOpenOverlay':
          event = UnifiedBannerAdEvent.onAdOpenOverlay;
          break;
        case 'onAdCloseOverlay':
          event = UnifiedBannerAdEvent.onAdCloseOverlay;
          break;
      }
      widget.adEventCallback(event, call.arguments);
    }
  }

  Future<void> closeAd() async {
    if(_methodChannel != null) {
      await _methodChannel.invokeMethod('close');
    }
  }

  Future<void> refreshAd() async {
    if(_methodChannel != null) {
      await _methodChannel.invokeMethod('refresh');
    }
  }

  @override
  void dispose() {
    closeAd();
    super.dispose();
  }
}