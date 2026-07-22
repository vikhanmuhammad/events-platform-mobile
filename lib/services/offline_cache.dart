import 'package:hive_flutter/hive_flutter.dart';

class OfflineCache {
  static final OfflineCache _instance = OfflineCache._internal();

  factory OfflineCache() => _instance;
  OfflineCache._internal();

  late Box<dynamic> _eventsBox;
  late Box<dynamic> _rsvpsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _eventsBox = await Hive.openBox('events');
    _rsvpsBox = await Hive.openBox('rsvps');
  }

  // Cache events
  Future<void> cacheEvents(List<dynamic> events) async {
    await _eventsBox.put('events_list', events);
    await _eventsBox.put('events_timestamp', DateTime.now().toIso8601String());
  }

  List<dynamic>? getCachedEvents() {
    return _eventsBox.get('events_list') as List<dynamic>?;
  }

  // Cache RSVPs locally (pending sync)
  Future<void> addPendingRsvp(String eventId, String status) async {
    final pending = _rsvpsBox.get('pending_rsvps', defaultValue: <String, String>{}) as Map;
    pending[eventId] = status;
    await _rsvpsBox.put('pending_rsvps', pending);
  }

  Map<String, String> getPendingRsvps() {
    return Map.from(_rsvpsBox.get('pending_rsvps', defaultValue: {}) as Map);
  }

  Future<void> clearPendingRsvp(String eventId) async {
    final pending = _rsvpsBox.get('pending_rsvps', defaultValue: {}) as Map;
    pending.remove(eventId);
    await _rsvpsBox.put('pending_rsvps', pending);
  }
}