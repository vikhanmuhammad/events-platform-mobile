import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/events_repository.dart';
import '../models/event_model.dart';
import '../services/location_service.dart';

final eventsRepositoryProvider = Provider((ref) => EventsRepository());

final eventFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'category': null,
      'distance': 25.0,
      'latitude': null,
      'longitude': null,
    });

final userLocationProvider =
    StateProvider<({double lat, double lon})?>((ref) => null);

final eventsProvider = FutureProvider.autoDispose
    .family<List<Event>, Map<String, dynamic>>((ref, params) async {
  // A one-time location snapshot (set once via currentLocationProvider),
  // not a live stream - the filter shouldn't silently change results out
  // from under the user as the device's GPS fix updates in the background.
  final location = ref.watch(currentLocationProvider);
  final repository = ref.watch(eventsRepositoryProvider);

  return repository.listEvents(
    category: params['category'],
    distance: params['distance'] ?? 25.0,
    latitude: location?.latitude,
    longitude: location?.longitude,
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