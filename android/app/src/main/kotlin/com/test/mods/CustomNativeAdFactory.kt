package com.test.mods

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.*
import com.google.android.gms.ads.nativead.*
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

fun Int.toPx(context: Context): Int {
    return TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, this.toFloat(), context.resources.displayMetrics
    ).toInt()
}

class CustomNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = NativeAdView(context)

        // Опція стилю
        val adStyle = customOptions?.get("adStyle") as? String ?: "grid"
        val useLargeCTA = adStyle == "flowPhase"
        val ctaHeightDp = if (useLargeCTA) 60f else 40f
        val ctaCornerRadius = if (useLargeCTA) 15f else 10f
        val ctaHeightPx = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, ctaHeightDp, context.resources.displayMetrics).toInt()

        // Основний контейнер
        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#252525"))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            background = GradientDrawable().apply {
                cornerRadius = 10f * context.resources.displayMetrics.density
                setColor(Color.parseColor("#252525"))
            }
            minimumHeight = minHeightPx
        }

        // Внутрішній контент з паддінгами
        val contentWrapper = RelativeLayout(context).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(10.toPx(context), 10.toPx(context), 10.toPx(context), 10.toPx(context))
        }

        // MediaView
        val mediaContainer = FrameLayout(context).apply {
            id = View.generateViewId()
            layoutParams = RelativeLayout.LayoutParams(180.toPx(context), 120.toPx(context)).apply {
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

        // AD Label
        val adLabel = TextView(context).apply {
            text = "AD"
            setTextColor(Color.WHITE)
            textSize = 12f
            alpha = 0.7f
            typeface = Typeface.DEFAULT_BOLD
            id = View.generateViewId()
        }

        // Headline + Body
        val headline = TextView(context).apply {
            text = nativeAd.headline
            setTextColor(Color.WHITE)
            textSize = 13f
            typeface = Typeface.DEFAULT_BOLD
        }

        val bodyText = TextView(context).apply {
            text = nativeAd.body ?: ""
            setTextColor(Color.LTGRAY)
            textSize = 11f
        }

        val textContentLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(headline)
            addView(bodyText)
        }

        val scrollableText = ScrollView(context).apply {
            id = View.generateViewId()
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.BELOW, adLabel.id)
                topMargin = 5.toPx(context)
            }
            addView(textContentLayout)
        }

        val textLayout = RelativeLayout(context).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.END_OF, mediaContainer.id)
                addRule(RelativeLayout.ALIGN_TOP, mediaContainer.id)
                marginStart = 10.toPx(context)
            }
            addView(adLabel)
            addView(scrollableText)
        }

        val adChoicesView = AdChoicesView(context).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_TOP)
                addRule(RelativeLayout.ALIGN_PARENT_END)
            }
        }

        contentWrapper.addView(mediaContainer)
        contentWrapper.addView(adChoicesView)
        contentWrapper.addView(textLayout)

        // Кнопка CTA поза паддінгами
        val callToAction = Button(context).apply {
            text = nativeAd.callToAction
            setTextColor(Color.parseColor("#8D8D8D"))
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                ctaHeightPx
            ).apply {
                topMargin = 10.toPx(context)
                bottomMargin = 15.toPx(context)
                marginStart = if (adStyle == "flowPhase") 0 else 10.toPx(context)
                marginEnd = if (adStyle == "flowPhase") 0 else 10.toPx(context)
            }
            background = GradientDrawable().apply {
                cornerRadius = ctaCornerRadius * context.resources.displayMetrics.density
                setColor(Color.parseColor("#586067"))
            }
        }

        container.addView(contentWrapper)
        container.addView(callToAction)

        adView.mediaView = mediaView
        adView.headlineView = headline
        adView.bodyView = bodyText
        adView.callToActionView = callToAction
        adView.adChoicesView = adChoicesView
        adView.setNativeAd(nativeAd)

        // Захист від випадкового кліку
        listOf(mediaView, headline, bodyText, adLabel, scrollableText, textLayout, contentWrapper, container).forEach {
            it.isClickable = false
        }

        adView.addView(container)
        return adView
    }
}


