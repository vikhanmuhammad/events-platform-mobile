import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/event_providers.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/gradient_app_bar.dart';
import 'event_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final locationService = ref.read(locationServiceProvider);
    final granted = await locationService.requestPermission();
    if (!granted) return;

    // One-time snapshot - deliberately not a live stream, so the events
    // filter doesn't silently shift out from under the user mid-session.
    final position = await locationService.getCurrentLocation();
    if (position != null && mounted) {
      ref.read(currentLocationProvider.notifier).state = position;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(eventFiltersProvider);
    final eventsAsync = ref.watch(eventsProvider(filters));
    final selectedCategory = filters['category'] as String?;

    // connectivity_plus v6+ reports a list of active connections; no active
    // connection means the list only contains ConnectivityResult.none.
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? const [ConnectivityResult.none];
        final isOffline = results.contains(ConnectivityResult.none);

        return Scaffold(
          appBar: GradientAppBar(
            title: 'Events Near You',
            titleTrailing: isOffline
                ? Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Offline',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: 'Log out?',
                    message:
                        "You'll need to log in again to access your events.",
                    confirmLabel: 'Logout',
                  );
                  if (confirmed) {
                    ref.read(authStateProvider.notifier).logout();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Category filter chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: selectedCategory == null,
                        onTap: () {
                          ref.read(eventFiltersProvider.notifier).state = {
                            ...filters,
                            'category': null,
                          };
                        },
                      ),
                      ...Constants.eventCategories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _CategoryChip(
                            label: category,
                            selected: selectedCategory == category,
                            onTap: () {
                              ref.read(eventFiltersProvider.notifier).state = {
                                ...filters,
                                'category': category,
                              };
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Events List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.refresh(eventsProvider(filters).future),
                  child: eventsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(child: Text('Error: $error')),
                        ),
                      ],
                    ),
                    data: (events) {
                      if (events.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: _EmptyState(),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EventCard(
                              title: event.title,
                              category: event.category,
                              locationName: event.locationName,
                              startTime: event.startTime,
                              attendeeCount: event.attendeeCount,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailScreen(eventId: event.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String category;
  final String locationName;
  final DateTime startTime;
  final int attendeeCount;
  final VoidCallback onTap;

  const _EventCard({
    required this.title,
    required this.category,
    required this.locationName,
    required this.startTime,
    required this.attendeeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryColors.of(category);

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: catColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$locationName • ${DateFormat('MMM d, h:mm a').format(startTime)}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Icon(Icons.people, size: 16, color: AppColors.brand500),
                  const SizedBox(height: 2),
                  Text(
                    '$attendeeCount',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No events found',
            style: TextStyle(
                color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
