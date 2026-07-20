import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_providers.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _rsvp(String status) async {
    setState(() => _isSubmitting = true);
    try {
      final repository = ref.read(eventsRepositoryProvider);
      await repository.rsvpEvent(widget.eventId, status);

      ref.invalidate(eventDetailProvider(widget.eventId));
      ref.invalidate(eventsProvider);
      ref.invalidate(userUpcomingEventsProvider);
      ref.invalidate(userPastEventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('RSVP updated: $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to RSVP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (event) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Chip(label: Text(event.category)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE, MMM d, y • h:mm a').format(event.startTime)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 8),
                    Text(event.locationName),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 18),
                    const SizedBox(width: 8),
                    Text('${event.attendeeCount} going'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(event.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text('RSVP', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _rsvp('GOING'),
                      child: const Text('Going'),
                    ),
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => _rsvp('INTERESTED'),
                      child: const Text('Interested'),
                    ),
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => _rsvp('CANT_GO'),
                      child: const Text("Can't Go"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
