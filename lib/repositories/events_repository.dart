import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/offline_cache.dart';

class EventsRepository {
  final ApiService _apiService = ApiService();
  final OfflineCache _cache = OfflineCache();

  Future<List<Event>> listEvents({
    String? category,
    double? distance,
    double? latitude,
    double? longitude,
    int limit = 10,
    int offset = 0,
  }) async {
    // Always attempt the live request first. connectivity_plus's pre-flight
    // check is unreliable on emulators/some networks (false "offline"
    // reports), so it must not gate whether we even try the network - it's
    // only used as a fallback signal if the real request fails below.
    try {
      final response = await _apiService.dio.get(
        '/events',
        queryParameters: {
          if (category != null) 'category': category,
          if (distance != null) 'distance': distance,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'limit': limit,
          'offset': offset,
        },
      );
      final eventsList = (response.data['events'] as List? ?? [])
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();

      // A location filter that finds nothing nearby shouldn't leave the
      // user with a dead-end empty screen - fall back to the unfiltered list.
      if (eventsList.isEmpty && latitude != null && longitude != null) {
        return listEvents(
          category: category,
          distance: distance,
          limit: limit,
          offset: offset,
        );
      }

      // Cache for offline
      await _cache.cacheEvents(eventsList.map((e) => e.toJson()).toList());

      return eventsList;
    } catch (e) {
      // Live request failed - fall back to cache if we have one.
      final cached = _cache.getCachedEvents();
      if (cached != null) {
        return cached
            .map((e) => Event.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      rethrow;
    }
  }

  Future<Event> getEvent(String id) async {
    try {
      final response = await _apiService.dio.get('/events/$id');
      return Event.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rsvpEvent(String eventId, String status) async {
    try {
      await _apiService.dio.post('/events/$eventId/rsvp', data: {'status': status});
    } catch (e) {
      // Live request failed - queue for later sync.
      await _cache.addPendingRsvp(eventId, status);
    }
  }

  Future<void> syncPendingRsvps() async {
    final pending = _cache.getPendingRsvps();
    for (final entry in pending.entries) {
      try {
        await _apiService.dio.post(
          '/events/${entry.key}/rsvp',
          data: {'status': entry.value},
        );
        await _cache.clearPendingRsvp(entry.key);
      } catch (e) {
        print('Failed to sync RSVP: $e');
      }
    }
  }

  Future<List<Event>> getUserUpcomingEvents() async {
    try {
      final response = await _apiService.dio.get('/users/me/events');
      final eventsList = response.data['events'] as List?;
      if (eventsList == null) {
        return [];
      }
      return eventsList.map((e) => _parseUserEvent(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Event>> getUserPastEvents() async {
    try {
      final response = await _apiService.dio.get('/users/me/past-events');
      final eventsList = response.data['events'] as List?;
      if (eventsList == null) {
        return [];
      }
      return eventsList.map((e) => _parseUserEvent(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // The /users/me endpoints report RSVP status under "your_status",
  // while Event.fromJson expects "user_rsvp_status".
  Event _parseUserEvent(dynamic e) {
    final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
    if (map['your_status'] != null) {
      map['user_rsvp_status'] = map['your_status'];
    }
    return Event.fromJson(map);
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['error'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}