package com.test.mods

import android.content.Context
import android.view.View
import android.view.LayoutInflater
import android.view.ViewGroup.LayoutParams
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.graphics.Color
import android.graphics.Typeface
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.NativeAdOptions
import com.google.android.gms.ads.nativead.NativeAd.Image
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.AdLoader
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory


class CustomNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = NativeAdView(context)

        // Container layout
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(20, 20, 20, 20)
            setBackgroundColor(Color.WHITE)
        }

        // Headline
        val headline = TextView(context).apply {
            text = nativeAd.headline
            textSize = 16f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.BLACK)
        }

        // Image (main)
        //val imageView = ImageView(context).apply {
        //    nativeAd.images.firstOrNull()?.drawable?.let { setImageDrawable(it) }
        //    layoutParams = LinearLayout.LayoutParams(
        //        LinearLayout.LayoutParams.MATCH_PARENT,
        //        250
        //    ).apply { setMargins(0, 10, 0, 10) }
        //    scaleType = ImageView.ScaleType.CENTER_CROP
        //}

        // MediaView (for the main image or video)
        val mediaView = MediaView(context).apply {
            nativeAd.mediaContent?.let { setMediaContent(it) }

            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                250
            ).apply {
                setMargins(0, 10, 0, 10)
            }
        }


        // CTA Button
        val callToAction = Button(context).apply {
            text = nativeAd.callToAction
            setBackgroundColor(Color.parseColor("#586067"))
            setTextColor(Color.WHITE)
            textSize = 14f
        }

        // Add views to container
        container.addView(mediaView)
        container.addView(headline)
        container.addView(callToAction)

        // Set native ad elements
        adView.mediaView = mediaView
        adView.headlineView = headline
        adView.callToActionView = callToAction
        adView.setNativeAd(nativeAd)

        adView.addView(container)

        return adView
    }
}
