import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';
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
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'My Events',
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
          _buildEventsList(isUpcoming: true),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  isUpcoming ? 'No upcoming events' : 'No past events',
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final Event event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MyEventCard(
                event: event,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(eventId: event.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _MyEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _MyEventCard({required this.event, required this.onTap});

  static const Map<String, Color> _statusColors = {
    'GOING': AppColors.success,
    'INTERESTED': AppColors.accent500,
    'CANT_GO': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryColors.of(event.category);
    final statusColor = _statusColors[event.userRsvpStatus] ?? Colors.grey;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            event.category,
                            style: TextStyle(
                              color: catColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      event.userRsvpStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${event.locationName} • ${DateFormat('MMM d, h:mm a').format(event.startTime)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.people, size: 14, color: AppColors.brand500),
                  const SizedBox(width: 4),
                  Text(
                    '${event.attendeeCount} going',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                  ),
                  const Spacer(),
                  const Text(
                    'View Details',
                    style: TextStyle(
                      color: AppColors.brand600,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 14, color: AppColors.brand600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
