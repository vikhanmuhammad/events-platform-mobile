import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class EventsRepository {
  final ApiService _apiService = ApiService();

  Future<List<Event>> listEvents({
    String? category,
    double? distance,
    double? latitude,
    double? longitude,
    int limit = 10,
    int offset = 0,
  }) async {
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

      final eventsList = response.data['events'] as List?;
      if (eventsList == null) {
        return [];
      }
      final events = eventsList
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
      return events;
    } on DioException catch (e) {
      throw _handleError(e);
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

  Future<void> rsvpEvent(String id, String status) async {
    try {
      await _apiService.dio.post(
        '/events/$id/rsvp',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw _handleError(e);
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