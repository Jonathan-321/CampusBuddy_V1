import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/theme.dart';
import '../blocs/dining/dining_bloc.dart';
import '../blocs/dining/dining_event.dart';
import '../blocs/dining/dining_state.dart';
import '../widgets/dining_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' as error_widget;
import '../../domain/entities/dining_info.dart';

class DiningScreen extends StatefulWidget {
  const DiningScreen({Key? key}) : super(key: key);

  @override
  State<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends State<DiningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showMealPlanOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load all dining options
    context.read<DiningBloc>().add(LoadAllDiningOptions());

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        context
            .read<DiningBloc>()
            .add(SearchDiningMenuItems(_searchController.text));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
            Tab(text: 'All Dining'),
            Tab(text: 'Search Menu'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DiningBloc>().add(RefreshDiningOptions());
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Dining Tab
          _buildAllDiningTab(),

          // Search Menu Tab
          _buildSearchMenuTab(),
        ],
      ),
    );
  }

  Widget _buildAllDiningTab() {
    return Column(
      children: [
        // Filter Options
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<DiningBloc>().add(LoadOpenDiningOptions());
                  },
                  icon: const Icon(Icons.access_time),
                  label: const Text('Open Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilterChip(
                  label: const Text('Meal Plan'),
                  selected: _showMealPlanOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showMealPlanOnly = selected;
                    });

                    if (selected) {
                      context.read<DiningBloc>().add(LoadMealPlanOptions());
                    } else {
                      context.read<DiningBloc>().add(LoadAllDiningOptions());
                    }
                  },
                  avatar: Icon(
                    Icons.card_membership,
                    color: _showMealPlanOnly
                        ? Colors.white
                        : AppTheme.primaryColor,
                  ),
                  backgroundColor: Colors.transparent,
                  selectedColor: AppTheme.primaryColor,
                  checkmarkColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Dining Options List
        Expanded(
          child: BlocBuilder<DiningBloc, DiningState>(
            builder: (context, state) {
              if (state is DiningLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is DiningOptionsLoaded) {
                return _buildDiningList(state.options);
              } else if (state is MealPlanOptionsLoaded) {
                return _buildDiningList(state.options);
              } else if (state is OpenDiningOptionsLoaded) {
                return _buildDiningList(state.options);
              } else if (state is NoDiningOptionsOpen) {
                return const Center(
                  child: Text('No dining options are currently open.'),
                );
              } else if (state is DiningError) {
                return error_widget.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<DiningBloc>().add(LoadAllDiningOptions());
                  },
                );
              } else if (state is DiningEmpty) {
                return const Center(
                  child: Text('No dining options available.'),
                );
              }
              return const Center(child: LoadingIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchMenuTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for menu items',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Search Results
        Expanded(
          child: BlocBuilder<DiningBloc, DiningState>(
            builder: (context, state) {
              if (_searchController.text.isEmpty) {
                return const Center(
                  child: Text('Enter a search term to find menu items'),
                );
              }

              if (state is DiningLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is DiningSearchResults) {
                return _buildMenuSearchResults(state.results);
              } else if (state is DiningSearchEmpty) {
                return Center(
                  child: Text('No menu items found for "${state.query}"'),
                );
              } else if (state is DiningError) {
                return error_widget.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<DiningBloc>().add(
                            SearchDiningMenuItems(_searchController.text),
                          );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiningList(List<DiningInfo> options) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DiningBloc>().add(RefreshDiningOptions());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DiningCard(
              diningInfo: options[index],
              onTap: () {
                _showDiningDetailsScreen(options[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSearchResults(Map<String, List<MenuItem>> results) {
    final locationNames = results.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: locationNames.length,
      itemBuilder: (context, index) {
        final location = locationNames[index];
        final menuItems = results[location]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ...menuItems.map((item) {
                return ListTile(
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.dietaryInfo.isNotEmpty) ...[
                            ...item.dietaryInfo.map((info) {
                              IconData icon;
                              switch (info.toLowerCase()) {
                                case 'vegetarian':
                                  icon = Icons.spa;
                                  break;
                                case 'vegan':
                                  icon = Icons.grass;
                                  break;
                                case 'gluten-free':
                                  icon = Icons.do_not_disturb_on;
                                  break;
                                default:
                                  icon = Icons.info;
                              }
                              return Tooltip(
                                message: info,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    icon,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showDiningDetailsScreen(DiningInfo diningInfo) {
    // Load the details for this dining option
    context.read<DiningBloc>().add(LoadDiningOptionDetails(diningInfo.id));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiningDetailsScreen(diningInfo: diningInfo),
      ),
    );
  }
}

class DiningDetailsScreen extends StatelessWidget {
  final DiningInfo diningInfo;

  const DiningDetailsScreen({
    Key? key,
    required this.diningInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(diningInfo.name),
      ),
      body: BlocBuilder<DiningBloc, DiningState>(
        builder: (context, state) {
          if (state is DiningLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is DiningOptionDetailsLoaded) {
            // Use the loaded details from the state
            final details = state.option;
            return _buildDiningDetails(context, details);
          } else {
            // Use the passed-in diningInfo if state doesn't have details yet
            return _buildDiningDetails(context, diningInfo);
          }
        },
      ),
    );
  }

  Widget _buildDiningDetails(BuildContext context, DiningInfo details) {
    final menuCategories = _getMenuCategories(details.menu);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with location image or placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: details.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(details.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: details.imageUrl == null
                ? Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // Location Info
          Text(
            details.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text(details.location),
            ],
          ),

          if (details.rating != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${details.rating}/5.0'),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Meal Plan Badge
          if (details.acceptsMealPlan)
            Chip(
              label: const Text('Accepts Meal Plan'),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              avatar: Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),

          const SizedBox(height: 16),

          // Description
          Text(details.description),

          const SizedBox(height: 24),

          // Hours
          const Text(
            'Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: details.hours.map((hour) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hour.day,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(hour.formattedHours),
                      ],
                    ),
                  );
                }).toList(),
              ),
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

          const SizedBox(height: 8),

          // Menu Categories Tabs
          if (menuCategories.isNotEmpty) ...[
            DefaultTabController(
              length: menuCategories.length,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: menuCategories.map((category) {
                      return Tab(text: category);
                    }).toList(),
                    labelColor: AppTheme.primaryColor,
                  ),
                  SizedBox(
                    height: 500, // Fixed height for menu items
                    child: TabBarView(
                      children: menuCategories.map((category) {
                        final categoryItems = details.menu
                            .where((item) => item.category == category)
                            .toList();

                        return ListView.builder(
                          itemCount: categoryItems.length,
                          itemBuilder: (context, index) {
                            final item = categoryItems[index];
                            return ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(item.description),
                              trailing: Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ] else ...[
            const Center(
              child: Text('No menu items available'),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getMenuCategories(List<MenuItem> menu) {
    final categories = <String>{};
    for (final item in menu) {
      categories.add(item.category);
    }
    return categories.toList();
  }
}
