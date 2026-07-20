import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/events_repository.dart';
import '../models/event_model.dart';

final eventsRepositoryProvider = Provider((ref) => EventsRepository());

final eventFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'category': null,
      'distance': 25.0,
      'latitude': null,
      'longitude': null,
    });

final userLocationProvider =
    StateProvider<({double lat, double lon})?>((ref) => null);

final eventsProvider = FutureProvider.family<List<Event>, Map<String, dynamic>>(
    (ref, params) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.listEvents(
    category: params['category'],
    distance: params['distance'],
    latitude: params['latitude'],
    longitude: params['longitude'],
  );
});

final eventDetailProvider =
    FutureProvider.family<Event, String>((ref, eventId) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getEvent(eventId);
});

final userUpcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getUserUpcomingEvents();
});

final userPastEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getUserPastEvents();
});
