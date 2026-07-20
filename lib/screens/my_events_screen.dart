import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import 'event_detail_screen.dart';

class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Events Tab
          _buildEventsList(isUpcoming: true),
          // Past Events Tab
          _buildEventsList(isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildEventsList({required bool isUpcoming}) {
    final eventsAsync = ref.watch(
      isUpcoming ? userUpcomingEventsProvider : userPastEventsProvider,
    );

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Text(isUpcoming ? 'No upcoming events' : 'No past events'),
          );
        }
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final Event event = events[index];
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
    );
  }
}