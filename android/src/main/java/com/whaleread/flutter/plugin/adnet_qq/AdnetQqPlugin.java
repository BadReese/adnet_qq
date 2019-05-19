package com.whaleread.flutter.plugin.adnet_qq;

import android.app.Activity;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AdnetQqPlugin */
public class AdnetQqPlugin implements MethodCallHandler {
  private static Registrar registrar;
  private static AdnetQqPlugin instance;
  private static Map<String, FlutterUnifiedInterstitial> unifiedInterstitialMap = new HashMap<>();

  private static SplashAd splashAd;

  public static Activity getActivity() {
    return registrar.activity();
  }

  public static Registrar getRegistrar() {
    return registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    AdnetQqPlugin.registrar = registrar;
    AdnetQqPlugin.instance = new AdnetQqPlugin();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), PluginSettings.PLUGIN_ID);
    channel.setMethodCallHandler(instance);
    registrar.platformViewRegistry().registerViewFactory(PluginSettings.UNIFIED_BANNER_VIEW_ID, new FlutterUnifiedBannerViewFactory(registrar.messenger()));
    registrar.platformViewRegistry().registerViewFactory(PluginSettings.NATIVE_EXPRESS_VIEW_ID, new FlutterNativeExpressViewFactory(registrar.messenger()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method) {
      case "config":
        Map arguments = (Map) call.arguments;
        PluginSettings.APP_ID = (String)arguments.get("appId");
        if(PluginSettings.APP_ID == null) {
          result.error("appId must be specified!", null, null);
          return;
        }
        result.success(true);
        break;
      case "createUnifiedInterstitialAd": {
        String posId = (String)((Map)call.arguments).get("posId");
        if(posId == null) {
          result.error("posId cannot be null!", null, null);
          return;
        }
        if(!unifiedInterstitialMap.containsKey(posId)) {
          unifiedInterstitialMap.put(posId, new FlutterUnifiedInterstitial(posId, registrar.messenger()));
        }
        result.success(true);
        break;
      }
      case "showSplash": {
        String posId = (String)((Map)call.arguments).get("posId");
        String backgroundImage = null;
        if(((Map)call.arguments).containsKey("backgroundImage")) {
          backgroundImage = (String)((Map)call.arguments).get("backgroundImage");
        }
        boolean forcePermissions = false;
        if(((Map)call.arguments).containsKey("forcePermissions")) {
          forcePermissions = (boolean)((Map)call.arguments).get("forcePermissions");
        }
        if(splashAd != null) {
          splashAd.close();
        }
        splashAd = new SplashAd(registrar.activity(), registrar.messenger(), posId, backgroundImage, forcePermissions);
        splashAd.show();
        break;
      }
      case "closeSplash": {
        if(splashAd != null) {
          splashAd.close();
          splashAd = null;
        }
      }
      default:
        result.notImplemented();
    }
  }
}
