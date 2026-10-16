import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/services/api_service.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final WebAPIService _webAPIService;
  final ApiService _apiService;

  NotificationRepository({
    WebAPIService? webAPIService,
    ApiService? apiService,
  })  : _webAPIService = webAPIService ?? WebAPIService(),
        _apiService = apiService ?? ApiService();

  WebAPIService get webAPIService => _webAPIService;
  ApiService get apiService => _apiService;

  /// Fetches remote notifications for the currently authenticated user if supported by the backend.
  ///
  /// Note on backend integration:
  /// The backend API does not currently expose a dedicated notifications endpoint
  /// (such as `/api/notifications/`). In accordance with requirements, we do not invent
  /// an unverified endpoint or generate fake server responses. Notifications are driven
  /// by authentic pickup events (booking, rescheduling, cancellation, and completion)
  /// retrieved from the authenticated pickup service.
  Future<List<NotificationItemModel>> fetchNotifications() async {
    // Backend lacks a dedicated notification endpoint.
    // Return empty list so we never invent endpoints or fake server responses.
    return [];
  }

  /// Marks a notification as read and persists its state for the current authenticated user.
  Future<bool> markAsRead(String id) async {
    try {
      final uid = await _resolveCurrentUserId();
      final storageKey =
          uid.isNotEmpty ? 'read_notifications_$uid' : 'read_notifications';
      final existingStr = await SpHelper.getString(storageKey);
      final List<String> readIds = existingStr != null
          ? List<String>.from(jsonDecode(existingStr) as List)
          : [];

      if (!readIds.contains(id)) {
        readIds.add(id);
        await SpHelper.saveString(storageKey, jsonEncode(readIds));
      }
      return true;
    } catch (e) {
      debugPrint('⚠️ [NOTIFICATION REPO] markAsRead error: $e');
      return true;
    }
  }

  /// Retrieves the set of persisted read notification IDs for the current user.
  Future<Set<String>> getReadNotificationIds() async {
    try {
      final uid = await _resolveCurrentUserId();
      final storageKey =
          uid.isNotEmpty ? 'read_notifications_$uid' : 'read_notifications';
      final existingStr = await SpHelper.getString(storageKey);
      if (existingStr != null && existingStr.trim().isNotEmpty) {
        final decoded = jsonDecode(existingStr);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toSet();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [NOTIFICATION REPO] getReadNotificationIds error: $e');
    }
    return {};
  }

  Future<String> _resolveCurrentUserId() async {
    final uid = await SpHelper.getString(sp_keys.keyUserId);
    if (uid != null && uid.trim().isNotEmpty) return uid.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefUid = prefs.getString(sp_keys.keyUserId) ??
          prefs.getString('user_id') ??
          prefs.getInt('user_id')?.toString();
      if (prefUid != null && prefUid.trim().isNotEmpty) return prefUid.trim();
    } catch (_) {}
    return '';
  }
}
