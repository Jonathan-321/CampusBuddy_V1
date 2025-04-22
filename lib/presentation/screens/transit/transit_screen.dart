import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransitScreen extends StatefulWidget {
  const TransitScreen({Key? key}) : super(key: key);

  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRoute = 'All';
  final List<String> _routeTypes = ['All', 'Campus', 'City', 'Express'];
  
  final List<TransitRoute> _routes = [
    TransitRoute(
      id: '1',
      name: 'Campus Loop',
      type: 'Campus',
      description: 'Circles the main campus with stops at all major buildings',
      schedule: 'Every 10 minutes from 7:00 AM to 10:00 PM',
      stops: [
        TransitStop(name: 'Student Center', time: '7:00 AM', status: 'On Time'),
        TransitStop(name: 'Library', time: '7:03 AM', status: 'On Time'),
        TransitStop(name: 'Science Building', time: '7:07 AM', status: 'On Time'),
        TransitStop(name: 'Dormitories', time: '7:12 AM', status: 'On Time'),
        TransitStop(name: 'Recreation Center', time: '7:15 AM', status: 'On Time'),
        TransitStop(name: 'Student Center', time: '7:20 AM', status: 'On Time'),
      ],
      color: Colors.blue,
      isActive: true,
    ),
    TransitRoute(
      id: '2',
      name: 'Downtown Express',
      type: 'Express',
      description: 'Direct service between campus and downtown',
      schedule: 'Every 30 minutes from 6:30 AM to 11:30 PM',
      stops: [
        TransitStop(name: 'Student Center', time: '6:30 AM', status: 'On Time'),
        TransitStop(name: 'Downtown Station', time: '6:45 AM', status: 'On Time'),
        TransitStop(name: 'Student Center', time: '7:00 AM', status: 'On Time'),
      ],
      color: Colors.green,
      isActive: true,
    ),
    TransitRoute(
      id: '3',
      name: 'City Connector',
      type: 'City',
      description: 'Connects campus to city shopping and entertainment districts',
      schedule: 'Every 20 minutes from 8:00 AM to 10:00 PM',
      stops: [
        TransitStop(name: 'Student Center', time: '8:00 AM', status: 'On Time'),
        TransitStop(name: 'Shopping Mall', time: '8:15 AM', status: 'On Time'),
        TransitStop(name: 'Entertainment District', time: '8:25 AM', status: 'On Time'),
        TransitStop(name: 'City Park', time: '8:35 AM', status: 'On Time'),
        TransitStop(name: 'Student Center', time: '8:50 AM', status: 'On Time'),
      ],
      color: Colors.orange,
      isActive: true,
    ),
    TransitRoute(
      id: '4',
      name: 'Airport Shuttle',
      type: 'Express',
      description: 'Direct service to the regional airport',
      schedule: 'Four times daily at 6:00 AM, 10:00 AM, 2:00 PM, and 6:00 PM',
      stops: [
        TransitStop(name: 'Student Center', time: '6:00 AM', status: 'On Time'),
        TransitStop(name: 'Airport Terminal', time: '6:45 AM', status: 'On Time'),
      ],
      color: Colors.purple,
      isActive: true,
    ),
    TransitRoute(
      id: '5',
      name: 'Night Owl',
      type: 'Campus',
      description: 'Late night service around campus and nearby areas',
      schedule: 'Every 30 minutes from 10:00 PM to 3:00 AM',
      stops: [
        TransitStop(name: 'Student Center', time: '10:00 PM', status: 'On Time'),
        TransitStop(name: 'Dormitories', time: '10:05 PM', status: 'On Time'),
        TransitStop(name: 'Off-Campus Housing', time: '10:15 PM', status: 'On Time'),
        TransitStop(name: 'Entertainment District', time: '10:25 PM', status: 'On Time'),
        TransitStop(name: 'Student Center', time: '10:30 PM', status: 'On Time'),
      ],
      color: Colors.indigo,
      isActive: false,
    ),
  ];
  
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
        title: const Text('Campus Transit'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Routes'),
            Tab(text: 'Map'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutesTab(),
          _buildMapTab(),
        ],
      ),
    );
  }
  
  Widget _buildRoutesTab() {
    return Column(
      children: [
        // Route type selector
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _routeTypes.length,
            itemBuilder: (context, index) {
              final routeType = _routeTypes[index];
              final isSelected = routeType == _selectedRoute;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(routeType),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRoute = routeType;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                ),
              );
            },
          ),
        ),
        
        // Routes list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _getFilteredRoutes().length,
            itemBuilder: (context, index) {
              final route = _getFilteredRoutes()[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    _showRouteDetails(route);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: route.color.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: route.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                route.type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                route.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: route.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                route.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: route.isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Route details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    route.schedule,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Next departures
                            const Text(
                              'Next Departures',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildNextDepartures(route),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMapTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Transit Map',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Interactive map coming soon!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Interactive transit map will be available in the next update!'),
                ),
              );
            },
            child: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }
  
  List<TransitRoute> _getFilteredRoutes() {
    if (_selectedRoute == 'All') {
      return _routes;
    }
    return _routes.where((route) => route.type == _selectedRoute).toList();
  }
  
  Widget _buildNextDepartures(TransitRoute route) {
    if (!route.isActive) {
      return Text(
        'Service not currently active',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey[500],
        ),
      );
    }
    
    return Column(
      children: route.stops.take(3).map((stop) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: route.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                stop.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(stop.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stop.time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(stop.status),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              stop.status,
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(stop.status),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'On Time':
        return Colors.green;
      case 'Delayed':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Routes'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter route or stop name',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement search
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
  
  void _showRouteDetails(TransitRoute route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Route header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: route.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            route.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            route.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: route.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        route.isActive ? 'Service Active' : 'Service Inactive',
                        style: TextStyle(
                          color: route.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Route description
                    Text(
                      route.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Schedule
                    const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route.schedule,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stops
                    const Text(
                      'Stops',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Route map placeholder
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Route Map',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stop list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: route.stops.length,
                      itemBuilder: (context, index) {
                        final stop = route.stops[index];
                        final isFirst = index == 0;
                        final isLast = index == route.stops.length - 1;
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline
                            SizedBox(
                              width: 24,
                              child: Column(
                                children: [
                                  // Top connector
                                  if (!isFirst)
                                    Container(
                                      width: 2,
                                      height: 12,
                                      color: route.color,
                                    ),
                                  
                                  // Stop indicator
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: route.color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  
                                  // Bottom connector
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: route.color,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Stop details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          stop.time,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(stop.status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            stop.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getStatusColor(stop.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Setting alert...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications),
                            label: const Text('Set Alert'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tracking feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.location_on),
                            label: const Text('Track Bus'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TransitRoute {
  final String id;
  final String name;
  final String type;
  final String description;
  final String schedule;
  final List<TransitStop> stops;
  final Color color;
  final bool isActive;

  TransitRoute({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.schedule,
    required this.stops,
    required this.color,
    required this.isActive,
  });
}

class TransitStop {
  final String name;
  final String time;
  final String status;

  TransitStop({
    required this.name,
    required this.time,
    required this.status,
  });
}
