import 'dart:convert';

class TextExtension {
  static String convertUTF8(String text) 
  {
    try 
    {
      return utf8.decode(text.codeUnits.toList());
    }
    catch (e) 
    {
      return text;
    }
  }
}