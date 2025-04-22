import 'package:flutter/material.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({Key? key}) : super(key: key);

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  String _selectedCategory = 'All';
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Sample campus locations data
  final List<Map<String, dynamic>> _campusLocations = [
    {
      'id': '1',
      'name': 'Main Building',
      'category': 'Academic',
      'description': 'Administrative offices and classrooms',
      'hours': '7:00 AM - 10:00 PM',
      'address': '123 University Ave',
      'coordinates': {'lat': 37.7749, 'lng': -122.4194},
      'amenities': ['Elevators', 'Restrooms', 'Vending Machines', 'Study Areas'],
      'image': '',
    },
    {
      'id': '2',
      'name': 'Science Center',
      'category': 'Academic',
      'description': 'Science labs and research facilities',
      'hours': '8:00 AM - 9:00 PM',
      'address': '200 Science Drive',
      'coordinates': {'lat': 37.7750, 'lng': -122.4195},
      'amenities': ['Labs', 'Restrooms', 'Study Areas'],
      'image': '',
    },
    {
      'id': '3',
      'name': 'University Library',
      'category': 'Academic',
      'description': 'Main campus library with study spaces',
      'hours': '7:00 AM - 12:00 AM',
      'address': '300 Library Lane',
      'coordinates': {'lat': 37.7751, 'lng': -122.4196},
      'amenities': ['Study Rooms', 'Computers', 'Printers', 'Cafe'],
      'image': '',
    },
    {
      'id': '4',
      'name': 'Student Center',
      'category': 'Services',
      'description': 'Student services and activities',
      'hours': '7:00 AM - 11:00 PM',
      'address': '400 Student Way',
      'coordinates': {'lat': 37.7752, 'lng': -122.4197},
      'amenities': ['Food Court', 'Bookstore', 'ATMs', 'Lounge'],
      'image': '',
    },
    {
      'id': '5',
      'name': 'Recreation Center',
      'category': 'Recreation',
      'description': 'Fitness facilities and sports courts',
      'hours': '6:00 AM - 10:00 PM',
      'address': '500 Fitness Blvd',
      'coordinates': {'lat': 37.7753, 'lng': -122.4198},
      'amenities': ['Gym', 'Pool', 'Basketball Courts', 'Locker Rooms'],
      'image': '',
    },
    {
      'id': '6',
      'name': 'University Housing',
      'category': 'Residential',
      'description': 'On-campus student housing',
      'hours': '24/7',
      'address': '600 Dorm Drive',
      'coordinates': {'lat': 37.7754, 'lng': -122.4199},
      'amenities': ['Laundry', 'Study Lounges', 'Kitchen', 'Common Areas'],
      'image': '',
    },
    {
      'id': '7',
      'name': 'Dining Hall',
      'category': 'Dining',
      'description': 'Main campus dining facility',
      'hours': '7:00 AM - 9:00 PM',
      'address': '700 Food Court Way',
      'coordinates': {'lat': 37.7755, 'lng': -122.4200},
      'amenities': ['Multiple Food Stations', 'Vegetarian Options', 'Allergen-Free Zone'],
      'image': '',
    },
    {
      'id': '8',
      'name': 'Health Center',
      'category': 'Services',
      'description': 'Student health and wellness services',
      'hours': '8:00 AM - 5:00 PM',
      'address': '800 Health Drive',
      'coordinates': {'lat': 37.7756, 'lng': -122.4201},
      'amenities': ['Medical Services', 'Counseling', 'Pharmacy'],
      'image': '',
    },
    {
      'id': '9',
      'name': 'Performing Arts Center',
      'category': 'Recreation',
      'description': 'Theater and performance spaces',
      'hours': '9:00 AM - 10:00 PM',
      'address': '900 Arts Way',
      'coordinates': {'lat': 37.7757, 'lng': -122.4202},
      'amenities': ['Auditorium', 'Practice Rooms', 'Gallery'],
      'image': '',
    },
    {
      'id': '10',
      'name': 'Engineering Building',
      'category': 'Academic',
      'description': 'Engineering classrooms and labs',
      'hours': '7:00 AM - 10:00 PM',
      'address': '1000 Engineering Drive',
      'coordinates': {'lat': 37.7758, 'lng': -122.4203},
      'amenities': ['Computer Labs', 'Workshop', 'Study Areas'],
      'image': '',
    },
  ];

  List<Map<String, dynamic>> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = List.from(_campusLocations);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterLocations();
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _selectedCategory == 'All') {
        _filteredLocations = List.from(_campusLocations);
      } else {
        _filteredLocations = _campusLocations.where((location) {
          final matchesQuery = query.isEmpty || 
              location['name'].toLowerCase().contains(query) ||
              location['description'].toLowerCase().contains(query);
          
          final matchesCategory = _selectedCategory == 'All' || 
              location['category'] == _selectedCategory;
          
          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search locations...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _showSearchBar = false;
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                autofocus: true,
              )
            : const Text('Campus Map'),
        actions: [
          if (!_showSearchBar)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 16),
                _buildFilterChip('All'),
                _buildFilterChip('Academic'),
                _buildFilterChip('Services'),
                _buildFilterChip('Recreation'),
                _buildFilterChip('Residential'),
                _buildFilterChip('Dining'),
                const SizedBox(width: 16),
              ],
            ),
          ),
          
          // Map placeholder
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.blue.withOpacity(0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 80,
                      color: Colors.blue.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Campus Map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map integration would be implemented here\nusing Google Maps or another mapping service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open map in full screen
                      },
                      icon: const Icon(Icons.fullscreen),
                      label: const Text('View Full Map'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Locations list
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Locations (${_filteredLocations.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Toggle list/grid view
                        },
                        icon: const Icon(Icons.list, size: 16),
                        label: const Text('List'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredLocations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No locations found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredLocations.length,
                          itemBuilder: (context, index) {
                            return _buildLocationCard(_filteredLocations[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get directions to current location
        },
        child: const Icon(Icons.directions),
        tooltip: 'Get directions',
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          _selectCategory(category);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue.withOpacity(0.2),
        checkmarkColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to location details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Location icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(location['category']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(location['category']),
                    color: _getCategoryColor(location['category']),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Location details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                          location['hours'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.directions),
                    onPressed: () {
                      // Get directions to this location
                    },
                    tooltip: 'Get directions',
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_outline),
                    onPressed: () {
                      // Add to favorites
                    },
                    tooltip: 'Add to favorites',
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return Colors.blue;
      case 'Services':
        return Colors.purple;
      case 'Recreation':
        return Colors.green;
      case 'Residential':
        return Colors.orange;
      case 'Dining':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school;
      case 'Services':
        return Icons.business;
      case 'Recreation':
        return Icons.sports_basketball;
      case 'Residential':
        return Icons.home;
      case 'Dining':
        return Icons.restaurant;
      default:
        return Icons.location_on;
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Locations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Filter options
              _buildFilterOption('All', Icons.location_on),
              _buildFilterOption('Academic', Icons.school),
              _buildFilterOption('Services', Icons.business),
              _buildFilterOption('Recreation', Icons.sports_basketball),
              _buildFilterOption('Residential', Icons.home),
              _buildFilterOption('Dining', Icons.restaurant),
              
              const SizedBox(height: 16),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String category, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: _getCategoryColor(category),
      ),
      title: Text(category),
      trailing: Radio<String>(
        value: category,
        groupValue: _selectedCategory,
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
          _filterLocations();
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _filterLocations();
        Navigator.pop(context);
      },
    );
  }
}
