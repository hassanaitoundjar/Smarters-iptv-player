import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../helpers/helpers.dart';

String kBanner = Platform.isAndroid
    ? "ca-app-pub-4228099303451066/1365018520" //TODO: Banner Android
    : "ca-app-pub-3940256099942544/2934735716"; //TODO: Banner IOS
String kInterstitial = Platform.isAndroid
    ? "ca-app-pub-4228099303451066/2843404117" //TODO: Interstitial Android
    : "ca-app-pub-3940256099942544/4411468910"; //TODO: Interstitial IOS

///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///

class AdmobWidget {
  static getBanner() {
    if (!showAds) {
      return const SizedBox(height: 10);
    }

    final BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
        debugPrint("Banner Loaded");
        // isLoaded = true;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        debugPrint('Ad failed to load: $error');
        // isLoaded = false;
      },
    );

    final BannerAd myBanner = BannerAd(
      adUnitId: kBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    );

    myBanner.load();
    final AdWidget adWidget = AdWidget(ad: myBanner);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: Center(child: adWidget),
    );
  }
}
