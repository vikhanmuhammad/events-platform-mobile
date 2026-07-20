import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/event_providers.dart';
import 'event_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(eventFiltersProvider);
    final eventsAsync = ref.watch(eventsProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Near You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter by Category:'),
                DropdownButton<String?>(
                  value: filters['category'],
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    const DropdownMenuItem(value: 'Tech', child: Text('Tech')),
                    const DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                    const DropdownMenuItem(value: 'Music', child: Text('Music')),
                  ],
                  onChanged: (value) {
                    ref.read(eventFiltersProvider.notifier).state = {
                      ...filters,
                      'category': value,
                    };
                  },
                ),
              ],
            ),
          ),
          // Events List
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('No events found'));
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.locationName} • ${DateFormat('MMM d, h:mm a').format(event.startTime)}',
                      ),
                      trailing: Text('${event.attendeeCount} going'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(eventId: event.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}