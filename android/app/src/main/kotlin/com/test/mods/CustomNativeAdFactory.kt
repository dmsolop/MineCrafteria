package com.test.mods

import android.content.Context
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.*
import com.google.android.gms.ads.nativead.*
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class CustomNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = NativeAdView(context)

        // 🔹 Основний контейнер – строго фіксована висота 290dp
        val containerHeight = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 290f, context.resources.displayMetrics).toInt()
        val container = RelativeLayout(context).apply {
            setBackgroundColor(Color.parseColor("#252525"))
            setPadding(20, 20, 20, 20)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                containerHeight
            ).apply { setMargins(0, 0, 0, 20) }
            background = GradientDrawable().apply {
                cornerRadius = 10f * context.resources.displayMetrics.density
                setColor(Color.parseColor("#252525"))
            }
        }

        // 🔹 Контейнер для MediaView (180x120dp)
        val mediaContainer = FrameLayout(context).apply {
            id = View.generateViewId()
            layoutParams = RelativeLayout.LayoutParams(
                TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 180f, context.resources.displayMetrics).toInt(),
                TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 120f, context.resources.displayMetrics).toInt()
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_START)
                addRule(RelativeLayout.ALIGN_PARENT_TOP)
            }
            clipChildren = true
        }

        // 🔹 MediaView – строго фіксований розмір
        val mediaView = MediaView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            nativeAd.mediaContent?.let { mediaContent = it }
        }

        mediaContainer.addView(mediaView)

        // 🔹 Текстовий блок праворуч від MediaView
        val textLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.END_OF, mediaContainer.id)
                addRule(RelativeLayout.ALIGN_TOP, mediaContainer.id)
                marginStart = 20
            }
        }

        // 🔹 AD-значок
        val adLabel = TextView(context).apply {
            text = "AD"
            setTextColor(Color.WHITE)
            textSize = 12f
            alpha = 0.7f
            typeface = Typeface.DEFAULT_BOLD
        }

        // 🔹 Headline
        val headline = TextView(context).apply {
            text = nativeAd.headline
            setTextColor(Color.WHITE)
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
        }

        textLayout.addView(adLabel)
        textLayout.addView(headline)

        // 🔹 CTA-кнопка – прив'язка до низу контейнера
        val callToAction = Button(context).apply {
            text = nativeAd.callToAction
            setBackgroundColor(Color.parseColor("#586067"))
            setTextColor(Color.parseColor("#8D8D8D"))
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 50f, context.resources.displayMetrics).toInt()
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                bottomMargin = 10
            }
            background = GradientDrawable().apply {
                cornerRadius = 15f * context.resources.displayMetrics.density
                setColor(Color.parseColor("#586067"))
            }
        }

        // 🔹 AdChoicesView у правому верхньому куті
        val adChoicesView = AdChoicesView(context).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_TOP)
                addRule(RelativeLayout.ALIGN_PARENT_END)
            }
        }

        // 🔹 Додавання в контейнер
        container.addView(mediaContainer)
        container.addView(adChoicesView)
        container.addView(textLayout)
        container.addView(callToAction)

        // 🔹 Налаштування adView
        adView.mediaView = mediaView
        adView.headlineView = headline
        adView.callToActionView = callToAction
        adView.adChoicesView = adChoicesView

        adView.setNativeAd(nativeAd)
        adView.addView(container)

        return adView
    }
}



