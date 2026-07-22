import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/event_model.dart';
import '../providers/event_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';
import 'event_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _jakarta = LatLng(-6.2088, 106.8456);

  Event? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(eventFiltersProvider);
    final eventsAsync = ref.watch(eventsProvider(filters));

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Map View',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(eventsProvider(filters).future),
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (events) {
          final markers = events.map((event) {
            final isSelected = _selectedEvent?.id == event.id;
            return Marker(
              point: LatLng(event.latitude, event.longitude),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => setState(() => _selectedEvent = event),
                child: Icon(
                  Icons.location_on,
                  color: isSelected ? AppColors.fuchsia500 : AppColors.brand600,
                  size: isSelected ? 44 : 38,
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _jakarta,
                  initialZoom: 12,
                  onTap: (_, __) => setState(() => _selectedEvent = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vikhanmuhammad.mobile',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: 16,
                right: 16,
                bottom: _selectedEvent != null ? 16 : -160,
                child: _selectedEvent == null
                    ? const SizedBox.shrink()
                    : _EventSummaryCard(
                        event: _selectedEvent!,
                        onClose: () => setState(() => _selectedEvent = null),
                        onViewDetails: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => EventDetailScreen(
                                    eventId: _selectedEvent!.id,
                                  ),
                                ),
                              )
                              .then((_) => setState(() => _selectedEvent = null));
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  final Event event;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const _EventSummaryCard({
    required this.event,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryColors.of(event.category);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
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
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${event.locationName} • ${DateFormat('MMM d, h:mm a').format(event.startTime)}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 13, color: AppColors.brand500),
                        const SizedBox(width: 3),
                        Text(
                          '${event.attendeeCount} going',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const Spacer(),
                        const Text(
                          'View Details',
                          style: TextStyle(
                            color: AppColors.brand600,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 13, color: AppColors.brand600),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: Colors.grey.shade400,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
