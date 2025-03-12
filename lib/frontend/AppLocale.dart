import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

mixin AppLocale {
  static const String title = 'title';

  static const String main_top_search = 'main_top_search';
  static const String main_category_all_mods = 'main_category_all_mods';
  static const String main_category_top = 'main_category_top';
  static const String main_category_npc = 'main_category_npc';
  static const String main_category_weapons = 'main_category_weapons';
  static const String main_category_vehicles = 'main_category_vehicles';
  static const String main_category_saves = 'main_category_saves';
  static const String main_category_items = 'main_category_items';

  static const String main_side_menu = 'main_side_menu';
  static const String main_side_premium = 'main_side_premium';
  static const String main_side_favorites = 'main_side_favorites';
  static const String main_side_new_mod = 'main_side_new_mod';
  static const String main_side_settings = 'main_side_settings';
  static const String main_side_discord = 'main_side_discord';
  static const String main_side_other_apps = 'main_side_other_apps';
  static const String main_side_version = 'main_side_version';

  static const String settings_title = 'settings_title';
  static const String settings_language = 'settings_language';
  static const String settings_instruction = 'settings_instruction';
  static const String settings_dark_mode = 'settings_dark_mode';
  static const String settings_reset_purchases = 'settings_reset_purchases';
  static const String settings_feedback = 'settings_feedback';
  static const String settings_rate_the_app = 'settings_rate_the_app';
  static const String settings_other = 'settings_other';

  static const String instruction_title_1 = 'instruction_title_1';
  static const String instruction_title_2 = 'instruction_title_2';
  static const String instruction_title_3 = 'instruction_title_3';
  static const String instruction_desc_1 = 'instruction_desc_1';
  static const String instruction_desc_2 = 'instruction_desc_2';
  static const String instruction_desc_3 = 'instruction_desc_3';

  static const String feedback_title = 'feedback_title';
  static const String feedback_desc = 'feedback_desc';
  static const String feedback_button = 'feedback_button';

  static const String new_mod_title = 'new_mod_title';
  static const String new_mod_subtitle1 = 'new_mod_subtitle1';
  static const String new_mod_subtitle2 = 'new_mod_subtitle2';
  static const String new_mod_hint1 = 'new_mod_hint1';
  static const String new_mod_hint2 = 'new_mod_hint2';
  static const String new_mod_button = 'new_mod_button';

  static const String favorites_title = 'favorites_title';

  static const String mod_view_install = 'mod_view_install';
  static const String mod_view_error_ads = 'mod_view_error_ads';
  static const String mod_view_how_to_install = 'mod_view_how_to_install';
  static const String mod_view_description = 'mod_view_description';
  static const String mod_view_author = 'mod_view_author';
  static const String mod_view_rate = 'mod_view_rate';
  static const String mod_view_watchads = 'mod_view_watchads';
  static const String mod_view_recommend = 'mod_view_recommend';
  static const String mod_view_delete = 'mod_view_delete';
  static const String mod_view_downloaded = 'mod_view_downloaded';

  static const String premium_view1_title = 'premium_view1_title';
  static const String premium_view2_title = 'premium_view2_title';
  static const String premium_view3_title = 'premium_view3_title';

  static const String premium_view_legal1 = 'premium_view_legal1';
  static const String premium_view_legal1_android =
      'premium_view_legal1_android';

  static const String premium_view_legal2 = 'premium_view_legal2';
  static const String premium_view_legal2_android =
      'premium_view_legal2_android';

  static const String premium_view_terms = 'premium_view_terms';
  static const String premium_view_and = 'premium_view_and';
  static const String premium_view_policy = 'premium_view_policy';

  static const String premium_view_button_next = 'premium_view_button_next';
  static const String premium_view_button_start_plan =
      'premium_view_button_start_plan';

  static const String premium_view3_removeads_title =
      'premium_view3_removeads_title';
  static const String premium_view3_premiummods_title =
      'premium_view3_premiummods_title';
  static const String premium_view3_addtofavorites_title =
      'premium_view3_addtofavorites_title';

  static const String premium_view3_removeads_desc =
      'premium_view3_removeads_desc';
  static const String premium_view3_premiummods_desc =
      'premium_view3_premiummods_desc';
  static const String premium_view3_addtofavorites_desc =
      'premium_view3_addtofavorites_desc';

  static const String premium_view4_3daysfree = 'premium_view4_3daysfree';
  static const String premium_view4_1month = 'premium_view4_1month';
  static const String premium_view4_1year = 'premium_view4_1year';

  static const String premium_view4_threedays_dynamic_price =
      'premium_view4_threedays_dynamic_price';
  static const String premium_view4_button_start = 'premium_view4_button_start';
  static const String premium_view4_button_buy = 'premium_view4_button_buy';
  static const String premium_view4_button_purchased =
      'premium_view4_button_purchased';

  static const String popup_loading = 'popup_loading';
  static const String premium_lifetime = 'premium_lifetime';

  static const String error_app = 'error_app';

  static bool IsRUS(BuildContext context) {
    return main_top_search.getString(context) == RU["main_top_search"];
  }

  static Future<Map<String, Map<String, String>>> readLocalizationJson(
      String jsonString) async {
    // Decode the JSON string into a List of dynamic objects
    List<dynamic> jsonData = jsonDecode(jsonString);

    // Create the localization map
    Map<String, Map<String, String>> localizationMap = {};

    // Iterate through each entry in the JSON data
    for (var entry in jsonData) {
      // Extract the key for this entry
      String localizationKey = entry['Key'];

      // Iterate through each language in the entry
      entry.forEach((lang, value) {
        // Skip the 'Key' field
        if (lang != 'Key') {
          // Initialize the language map if it doesn't exist
          if (!localizationMap.containsKey(lang)) {
            localizationMap[lang] = {};
          }
          // Add the localization key and value to the appropriate language map
          localizationMap[lang]![localizationKey] = value ?? '';
        }
      });
    }

    return localizationMap;
  }

  static String categoryIndexToString(int index, BuildContext context) {
    switch (index) {
      case 0:
        return main_category_all_mods.getString(context);

      case 1:
        return main_category_top.getString(context);

      case 2:
        return main_category_npc.getString(context);

      case 3:
        return main_category_weapons.getString(context);

      case 4:
        return main_category_vehicles.getString(context);

      case 5:
        return main_category_saves.getString(context);

      case 6:
        return main_category_items.getString(context);
    }

    return "";
  }

  static Map<String, dynamic> EN = {},
      RU = {},
      FR = {},
      PT = {},
      ES = {},
      DE = {};
}
