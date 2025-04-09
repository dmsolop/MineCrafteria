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

        // Determining the height of the CTA button
        val adStyle = customOptions?.get("adStyle") as? String ?: "grid"
        val screenWidthDp = context.resources.displayMetrics.widthPixels / context.resources.displayMetrics.density
        val useLargeCTA = when (adStyle) {
            "flowPhase" -> true
            else -> false
        }
        val ctaHeightDp = if (useLargeCTA) 60f else 40f
        val ctaCornerRadius = if (useLargeCTA) 15f else 10f
        val ctaHeightPx = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, ctaHeightDp, context.resources.displayMetrics).toInt()

        // Minimum height: MediaView + padding + CTA + container padding
        val minHeightDp = 120f + 15f + ctaHeightDp + 30f
        val minHeightPx = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, minHeightDp, context.resources.displayMetrics).toInt()

        // Main container
        val container = RelativeLayout(context).apply {
            setBackgroundColor(Color.parseColor("#252525"))
            setPadding(10.toPx(context), 10.toPx(context), 10.toPx(context), 10.toPx(context))
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.WRAP_CONTENT // Адаптивна висота
            )
            background = GradientDrawable().apply {
                cornerRadius = 10f * context.resources.displayMetrics.density
                setColor(Color.parseColor("#252525"))
            }
        }

        // MediaContainer 180x120dp
        val mediaContainer = FrameLayout(context).apply {
            id = View.generateViewId()
            layoutParams = RelativeLayout.LayoutParams(
                180.toPx(context), 120.toPx(context)
            ).apply {
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

        val callToAction = Button(context).apply {
            text = nativeAd.callToAction
            setTextColor(Color.parseColor("#8D8D8D"))
            textSize = 16f
            //val baseTypeface = ResourcesCompat.getFont(context, R.font.joystix)
            //typeface = Typeface.create(baseTypeface, Typeface.BOLD)
            typeface = Typeface.DEFAULT_BOLD
            //typeface = Typeface.createFromAsset(context.assets, "fonts/Joystix.ttf")
            gravity = Gravity.CENTER
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                ctaHeightPx
            ).apply {
                addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                bottomMargin = 15.toPx(context)
            }
            background = GradientDrawable().apply {
                cornerRadius = ctaCornerRadius * context.resources.displayMetrics.density
                setColor(Color.parseColor("#586067"))
            }
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

        container.addView(mediaContainer)
        container.addView(adChoicesView)
        container.addView(textLayout)
        container.addView(callToAction)

        adView.mediaView = mediaView
        adView.headlineView = headline
        adView.bodyView = bodyText
        adView.callToActionView = callToAction
        adView.adChoicesView = adChoicesView

        adView.setNativeAd(nativeAd)

        mediaView.isClickable = false
        headline.isClickable = false
        bodyText.isClickable = false
        adLabel.isClickable = false
        scrollableText.isClickable = false
        textLayout.isClickable = false
        container.isClickable = false

        adView.addView(container)

        return adView
    }
}

