import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiningScreen extends StatefulWidget {
  const DiningScreen({Key? key}) : super(key: key);

  @override
  State<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends State<DiningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMeal = 'Lunch';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  final List<DiningLocation> _diningLocations = [
    DiningLocation(
      id: '1',
      name: 'Main Dining Hall',
      description:
          'The primary dining facility on campus with a variety of food stations.',
      hours: 'Mon-Fri: 7:00 AM - 9:00 PM\nSat-Sun: 8:00 AM - 8:00 PM',
      mealOptions: {
        'Breakfast': [
          MenuItem(
              name: 'Scrambled Eggs',
              description: 'Fresh scrambled eggs',
              price: 3.99,
              isVegetarian: true),
          MenuItem(
              name: 'Pancakes',
              description: 'Stack of fluffy pancakes with syrup',
              price: 4.99,
              isVegetarian: true),
          MenuItem(
              name: 'Bacon', description: 'Crispy bacon strips', price: 2.99),
          MenuItem(
              name: 'Oatmeal',
              description: 'Hearty oatmeal with toppings',
              price: 3.49,
              isVegetarian: true,
              isVegan: true),
        ],
        'Lunch': [
          MenuItem(
              name: 'Burger',
              description: 'Classic beef burger with fries',
              price: 7.99),
          MenuItem(
              name: 'Caesar Salad',
              description: 'Fresh romaine with Caesar dressing',
              price: 6.99,
              isVegetarian: true),
          MenuItem(
              name: 'Veggie Wrap',
              description: 'Vegetables in a whole wheat wrap',
              price: 6.49,
              isVegetarian: true,
              isVegan: true),
          MenuItem(
              name: 'Pizza Slice',
              description: 'Cheese or pepperoni pizza slice',
              price: 3.99,
              isVegetarian: true),
        ],
        'Dinner': [
          MenuItem(
              name: 'Grilled Chicken',
              description: 'Herb-marinated chicken breast',
              price: 8.99),
          MenuItem(
              name: 'Pasta Primavera',
              description: 'Pasta with seasonal vegetables',
              price: 7.99,
              isVegetarian: true),
          MenuItem(
              name: 'Steak',
              description: 'Grilled sirloin steak with sides',
              price: 12.99),
          MenuItem(
              name: 'Tofu Stir Fry',
              description: 'Tofu with vegetables and rice',
              price: 7.49,
              isVegetarian: true,
              isVegan: true),
        ],
      },
      rating: 4.2,
      currentCapacity: 65,
    ),
    DiningLocation(
      id: '2',
      name: 'Student Union Café',
      description: 'Quick-service café with coffee, sandwiches, and snacks.',
      hours: 'Mon-Fri: 7:30 AM - 7:00 PM\nSat: 9:00 AM - 5:00 PM\nSun: Closed',
      mealOptions: {
        'Breakfast': [
          MenuItem(
              name: 'Breakfast Sandwich',
              description: 'Egg and cheese on a bagel',
              price: 4.99,
              isVegetarian: true),
          MenuItem(
              name: 'Yogurt Parfait',
              description: 'Yogurt with granola and berries',
              price: 3.99,
              isVegetarian: true),
          MenuItem(
              name: 'Coffee',
              description: 'Freshly brewed coffee',
              price: 1.99,
              isVegetarian: true,
              isVegan: true),
          MenuItem(
              name: 'Muffin',
              description: 'Assorted fresh muffins',
              price: 2.49,
              isVegetarian: true),
        ],
        'Lunch': [
          MenuItem(
              name: 'Turkey Club',
              description: 'Turkey, bacon, lettuce, tomato',
              price: 6.99),
          MenuItem(
              name: 'Hummus Plate',
              description: 'Hummus with pita and vegetables',
              price: 5.99,
              isVegetarian: true,
              isVegan: true),
          MenuItem(
              name: 'Soup of the Day',
              description: 'Daily rotating soup selection',
              price: 3.99),
          MenuItem(
              name: 'Chicken Wrap',
              description: 'Grilled chicken wrap with veggies',
              price: 6.49),
        ],
        'Dinner': [
          MenuItem(
              name: 'Panini', description: 'Hot pressed sandwich', price: 6.99),
          MenuItem(
              name: 'Salad Bowl',
              description: 'Build your own salad',
              price: 7.99,
              isVegetarian: true),
          MenuItem(
              name: 'Quesadilla',
              description: 'Cheese quesadilla with salsa',
              price: 5.99,
              isVegetarian: true),
          MenuItem(
              name: 'Smoothie',
              description: 'Fruit smoothie with protein',
              price: 4.99,
              isVegetarian: true,
              isVegan: true),
        ],
      },
      rating: 4.0,
      currentCapacity: 40,
    ),
    DiningLocation(
      id: '3',
      name: 'Science Building Kiosk',
      description: 'Grab-and-go options for busy students.',
      hours: 'Mon-Fri: 8:00 AM - 4:00 PM\nSat-Sun: Closed',
      mealOptions: {
        'Breakfast': [
          MenuItem(
              name: 'Bagel',
              description: 'Plain or everything bagel',
              price: 2.49,
              isVegetarian: true),
          MenuItem(
              name: 'Fruit Cup',
              description: 'Fresh seasonal fruit',
              price: 3.49,
              isVegetarian: true,
              isVegan: true),
          MenuItem(
              name: 'Energy Bar',
              description: 'Protein or granola bar',
              price: 1.99,
              isVegetarian: true),
        ],
        'Lunch': [
          MenuItem(
              name: 'Pre-made Sandwich',
              description: 'Assorted pre-made sandwiches',
              price: 5.99),
          MenuItem(
              name: 'Chips',
              description: 'Assorted chips',
              price: 1.49,
              isVegetarian: true,
              isVegan: true),
          MenuItem(
              name: 'Bottled Drinks',
              description: 'Water, soda, juice',
              price: 1.99,
              isVegetarian: true,
              isVegan: true),
        ],
        'Dinner': [
          MenuItem(
              name: 'Closed',
              description: 'Not available for dinner',
              price: 0.0),
        ],
      },
      rating: 3.5,
      currentCapacity: 20,
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
        title: const Text('Campus Dining'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Locations'),
            Tab(text: 'Meal Plan'),
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
          _buildLocationsTab(),
          _buildMealPlanTab(),
        ],
      ),
    );
  }

  Widget _buildLocationsTab() {
    return Column(
      children: [
        // Meal type selector
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mealTypes.length,
            itemBuilder: (context, index) {
              final mealType = _mealTypes[index];
              final isSelected = mealType == _selectedMeal;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(mealType),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMeal = mealType;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.orange.withOpacity(0.2),
                  checkmarkColor: Colors.orange,
                ),
              );
            },
          ),
        ),

        // Dining locations list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _diningLocations.length,
            itemBuilder: (context, index) {
              final location = _diningLocations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    _showLocationDetails(location);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location header
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          image: DecorationImage(
                            image: AssetImage(index == 0
                                ? 'assets/images/Campus-dininghall.jpg'
                                : index == 1
                                    ? 'assets/images/dining_station.jpg'
                                    : 'assets/images/food.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[300],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        location.rating.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.people,
                                        size: 16,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${location.currentCapacity}% Full',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildCapacityIndicator(location.currentCapacity),
                          ],
                        ),
                      ),

                      // Location details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.description,
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
                                Text(
                                  _getFormattedHours(location.hours),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Menu preview
                            const Text(
                              'Menu Preview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuPreview(location, _selectedMeal),
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

  Widget _buildMealPlanTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.credit_card,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Meal Plan Information',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon!',
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
                  content: Text(
                      'Meal plan management will be available in the next update!'),
                ),
              );
            },
            child: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityIndicator(int capacity) {
    Color color;
    if (capacity < 50) {
      color = Colors.green;
    } else if (capacity < 80) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$capacity%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getFormattedHours(String hours) {
    // Get only the first line of hours (today's hours)
    final firstLine = hours.split('\n').first;
    return firstLine;
  }

  Widget _buildMenuPreview(DiningLocation location, String mealType) {
    final menuItems = location.mealOptions[mealType] ?? [];

    if (menuItems.isEmpty ||
        (menuItems.length == 1 && menuItems.first.name == 'Closed')) {
      return const Text(
        'Not available for this meal',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    return Column(
      children: menuItems
          .take(3)
          .map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.isVegetarian)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.eco,
                          size: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Dining Options'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter food or location',
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

  void _showLocationDetails(DiningLocation location) {
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

                    // Location image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location name and rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 20,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location.rating.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Capacity
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Current Capacity: ${location.currentCapacity}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      location.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hours
                    const Text(
                      'Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.hours,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu
                    const Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meal tabs
                    DefaultTabController(
                      length: _mealTypes.length,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: _mealTypes
                                .map((type) => Tab(text: type))
                                .toList(),
                            labelColor: Colors.orange,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.orange,
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              children: _mealTypes.map((type) {
                                final menuItems =
                                    location.mealOptions[type] ?? [];

                                if (menuItems.isEmpty ||
                                    (menuItems.length == 1 &&
                                        menuItems.first.name == 'Closed')) {
                                  return Center(
                                    child: Text(
                                      'Not available for $type',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  itemCount: menuItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    final item = menuItems[index];
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(item.description),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (item.isVegetarian)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.eco,
                                                        size: 12,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Vegetarian',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.green[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              if (item.isVegan)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.spa,
                                                        size: 12,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Vegan',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.green[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
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
                                  content: Text('Opening in Maps...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions'),
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
                                  content: Text('Order feature coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Order'),
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

class DiningLocation {
  final String id;
  final String name;
  final String description;
  final String hours;
  final Map<String, List<MenuItem>> mealOptions;
  final double rating;
  final int currentCapacity;

  DiningLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.hours,
    required this.mealOptions,
    required this.rating,
    required this.currentCapacity,
  });
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final bool isVegetarian;
  final bool isVegan;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    this.isVegetarian = false,
    this.isVegan = false,
  });
}
