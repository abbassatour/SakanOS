// lib/l10n/cubit/locale_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ar', 'AE')) {
    _loadSavedLocale();
  }

  static const String _localeKey = 'selected_app_language';

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_localeKey) ?? 'ar';
    emit(Locale(savedLanguage));
  }

  Future<void> changeLanguage(String languageCode) async {
    if (state.languageCode == languageCode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    emit(Locale(languageCode));
  }
}
