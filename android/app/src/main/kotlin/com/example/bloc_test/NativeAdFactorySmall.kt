package com.example.bloc_test
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactorySmall(
    private val context: Context
) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {

        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ads_small, null) as NativeAdView

        // Icon
        adView.iconView = adView.findViewById(R.id.native_ad_icon)
        val iconDrawable = nativeAd.icon?.drawable
        if (iconDrawable != null) {
            (adView.iconView as ImageView).setImageDrawable(iconDrawable)
        } else {
            adView.iconView?.visibility = View.GONE
        }

        // Call-to-action button
        adView.callToActionView = adView.findViewById(R.id.native_ad_button)
        val cta = nativeAd.callToAction
        if (cta != null) {
            (adView.callToActionView as Button).text = cta
        } else {
            adView.callToActionView?.visibility = View.GONE
        }

        // Headline
        adView.headlineView = adView.findViewById(R.id.native_ad_headline)
        (adView.headlineView as TextView).text = nativeAd.headline

        // Body
        adView.bodyView = adView.findViewById(R.id.native_ad_body)
        val bodyText = nativeAd.body
        if (bodyText != null) {
            (adView.bodyView as TextView).text = bodyText
        } else {
            adView.bodyView?.visibility = View.GONE
        }

        // Set the NativeAd
        adView.setNativeAd(nativeAd)

        return adView
    }
}
