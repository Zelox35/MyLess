import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Otomatik tespit: Android emülatör için 10.0.2.2, Web/Desktop/iOS için localhost
  static String baseUrl = (!kIsWeb && Platform.isAndroid)
      ? 'http://10.0.2.2:5678/webhook'
      : 'http://localhost:5678/webhook';

  static String get chatEndpoint => '$baseUrl/chat';
  static String get summarizeEndpoint => '$baseUrl/summarize';
  static String get generateQuizEndpoint => '$baseUrl/generate-quiz';
  static String get evaluateQuizEndpoint => '$baseUrl/evaluate-quiz';
  static String get flashcardsEndpoint => '$baseUrl/flashcards';
  static String get weeklyReportEndpoint => '$baseUrl/weekly-report';
  static String get extractImageEndpoint => '$baseUrl/extract-image';
  static String get registerEndpoint => '$baseUrl/register';
  static String get loginEndpoint => '$baseUrl/login';

  static const Duration timeoutDuration = Duration(seconds: 90);

  static void updateBaseUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      baseUrl = newUrl;
    }
  }
}
