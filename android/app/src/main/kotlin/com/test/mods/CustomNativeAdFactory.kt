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

        // 🔹 Ширина екрану (для CTA висоти)
        val screenWidthDp = context.resources.displayMetrics.widthPixels / context.resources.displayMetrics.density
        val ctaHeightDp = if (screenWidthDp >= 600) 60f else 40f
        val ctaHeightPx = dpToPx(ctaHeightDp)

        // 🔹 Мінімальна висота: 120 (MediaView) + 15 (відступ) + CTA + 40 (padding)
        val minHeightPx = dpToPx(120f + 15f + ctaHeightDp + 40f)

        // 🔹 Контейнер реклами
        val container = RelativeLayout(context).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            )
            minimumHeight = minHeightPx
            setPadding(20, 20, 20, 20)  // padding = 20dp з кожного боку
            background = GradientDrawable().apply {
                cornerRadius = dpToPx(10f).toFloat()
                setColor(Color.parseColor("#252525"))
            }
        }

        // 🔹 MediaView 180x120dp
        val mediaContainer = FrameLayout(context).apply {
            id = View.generateViewId()
            layoutParams = RelativeLayout.LayoutParams(dpToPx(180f), dpToPx(120f)).apply {
                addRule(RelativeLayout.ALIGN_PARENT_START)
                addRule(RelativeLayout.ALIGN_PARENT_TOP)
            }
            clipChildren = true
        }

        val mediaView = MediaView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            nativeAd.mediaContent?.let { mediaContent = it }
        }

        mediaContainer.addView(mediaView)

        // 🔹 Текст справа від MediaView
        val textLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.END_OF, mediaContainer.id)
                addRule(RelativeLayout.ALIGN_TOP, mediaContainer.id)
                marginStart = dpToPx(15f)
            }
        }

        val adLabel = TextView(context).apply {
            text = "AD"
            setTextColor(Color.WHITE)
            textSize = 12f
            alpha = 0.7f
            typeface = Typeface.DEFAULT_BOLD
        }

        val headline = TextView(context).apply {
            text = nativeAd.headline
            setTextColor(Color.WHITE)
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
        }

        textLayout.addView(adLabel)
        textLayout.addView(headline)

        // 🔹 Кнопка CTA
        val callToAction = Button(context).apply {
            text = nativeAd.callToAction
            setTextColor(Color.parseColor("#8D8D8D"))
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                ctaHeightPx
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                bottomMargin = dpToPx(15f)
            }
            background = GradientDrawable().apply {
                cornerRadius = dpToPx(10f).toFloat()
                setColor(Color.parseColor("#586067"))
            }
        }

        // 🔹 AdChoicesView (обов’язковий для Google)
        val adChoicesView = AdChoicesView(context).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_TOP)
                addRule(RelativeLayout.ALIGN_PARENT_END)
            }
        }

        // 🔹 Додаємо все в контейнер
        container.addView(mediaContainer)
        container.addView(textLayout)
        container.addView(callToAction)
        container.addView(adChoicesView)

        // 🔹 Прив’язка до NativeAdView
        adView.mediaView = mediaView
        adView.headlineView = headline
        adView.callToActionView = callToAction
        adView.adChoicesView = adChoicesView
        adView.setNativeAd(nativeAd)
        adView.addView(container)

        return adView
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            context.resources.displayMetrics
        ).toInt()
    }
}
