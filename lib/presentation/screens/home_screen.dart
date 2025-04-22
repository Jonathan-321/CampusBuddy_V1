import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/emergency/emergency_bloc.dart';
import '../blocs/emergency/emergency_event.dart';
import '../blocs/emergency/emergency_state.dart';
import '../blocs/directory/directory_bloc.dart';
import '../blocs/directory/directory_event.dart';
import '../blocs/directory/directory_state.dart';
import '../blocs/dining/dining_bloc.dart';
import '../blocs/dining/dining_event.dart';
import '../blocs/dining/dining_state.dart';
import '../blocs/events/events_bloc.dart';
import '../blocs/events/events_event.dart';
import '../blocs/events/events_state.dart';
import '../blocs/map/map_bloc.dart';
import '../blocs/map/map_event.dart';
import '../blocs/map/map_state.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/dining_card.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const EmergencyPage(),
    const DirectoryPage(),
    const DiningPage(),
    const EventsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Campus Buddy'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Show search functionality
                    showSearch(
                      context: context,
                      delegate: CampusSearchDelegate(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Show notifications
                  },
                ),
              ],
            ),
            drawer: CustomDrawer(user: state.user),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emergency),
                  label: 'Emergency',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Directory',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Dining',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Events',
                ),
              ],
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load emergency contacts
    context.read<EmergencyBloc>().add(LoadEmergencyOnlyContacts());
    // Load open dining options
    context.read<DiningBloc>().add(LoadOpenDiningOptions());
    // Load upcoming events
    context.read<EventsBloc>().add(LoadUpcomingEvents());
    // Load recommended locations
    context.read<MapBloc>().add(LoadRecommendedLocations());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EmergencyBloc>().add(RefreshEmergencyContacts());
        context.read<DiningBloc>().add(RefreshDiningOptions());
        context.read<EventsBloc>().add(RefreshEvents());
        context.read<MapBloc>().add(RefreshLocations());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.waving_hand,
                          size: 24,
                          color: Colors.yellow[700],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Welcome to Campus Buddy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your comprehensive guide to campus life',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRouter.map);
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Explore Campus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Contacts
            _buildSectionTitle(
                'Emergency Contacts', Icons.emergency, AppRouter.emergency),

            const SizedBox(height: 8),

            _buildEmergencyContacts(),

            const SizedBox(height: 24),

            // Open Dining Options
            _buildSectionTitle('Open Now', Icons.restaurant, AppRouter.dining),

            const SizedBox(height: 8),

            _buildOpenDiningOptions(),

            const SizedBox(height: 24),

            // Upcoming Events
            _buildSectionTitle(
                'Upcoming Events', Icons.event, AppRouter.events),

            const SizedBox(height: 8),

            _buildUpcomingEvents(),

            const SizedBox(height: 24),

            // Quick Access Buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Quick Access',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickAccessButton(
                  context,
                  'Campus Map',
                  Icons.map,
                  AppRouter.map,
                  AppTheme.accentColor,
                ),
                _buildQuickAccessButton(
                  context,
                  'Faculty Directory',
                  Icons.contact_phone,
                  AppRouter.directory,
                  Colors.purple,
                ),
                _buildQuickAccessButton(
                  context,
                  'Dining Menus',
                  Icons.restaurant_menu,
                  AppRouter.dining,
                  Colors.orange,
                ),
                _buildQuickAccessButton(
                  context,
                  'My Profile',
                  Icons.person,
                  AppRouter.profile,
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(route);
          },
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildEmergencyContacts() {
    return BlocBuilder<EmergencyBloc, EmergencyState>(
      builder: (context, state) {
        if (state is EmergencyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EmergencyOnlyContactsLoaded) {
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.contacts.length > 3 ? 3 : state.contacts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: SizedBox(
                    width: 280,
                    child: EmergencyContactCard(
                      contact: state.contacts[index],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is EmergencyEmpty) {
          return const Center(
            child: Text('No emergency contacts found'),
          );
        } else if (state is EmergencyError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildOpenDiningOptions() {
    return BlocBuilder<DiningBloc, DiningState>(
      builder: (context, state) {
        if (state is DiningLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OpenDiningOptionsLoaded) {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.options.length > 3 ? 3 : state.options.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: SizedBox(
                    width: 280,
                    child: DiningCard(
                      diningInfo: state.options[index],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is NoDiningOptionsOpen) {
          return const Center(
            child: Text('No dining options currently open'),
          );
        } else if (state is DiningError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildUpcomingEvents() {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UpcomingEventsLoaded) {
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.events.length > 3 ? 3 : state.events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: SizedBox(
                    width: 280,
                    child: EventCard(
                      event: state.events[index],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is EventsEmpty) {
          return const Center(
            child: Text('No upcoming events'),
          );
        } else if (state is EventsError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for bottom navigation
class EmergencyPage extends StatelessWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. The actual content is in emergency_screen.dart
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.emergency);
        },
        child: const Text('Go to Emergency Screen'),
      ),
    );
  }
}

class DirectoryPage extends StatelessWidget {
  const DirectoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. The actual content is in directory_screen.dart
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.directory);
        },
        child: const Text('Go to Directory Screen'),
      ),
    );
  }
}

class DiningPage extends StatelessWidget {
  const DiningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. The actual content is in dining_screen.dart
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.dining);
        },
        child: const Text('Go to Dining Screen'),
      ),
    );
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. The actual content is in events_screen.dart
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.events);
        },
        child: const Text('Go to Events Screen'),
      ),
    );
  }
}

class CampusSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Please enter a search term'),
      );
    }

    // Trigger search in different blocs
    context.read<DirectoryBloc>().add(SearchDirectoryEntries(query));
    context.read<DiningBloc>().add(SearchDiningMenuItems(query));
    context.read<MapBloc>().add(SearchLocations(query));

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Directory'),
              Tab(text: 'Dining'),
              Tab(text: 'Locations'),
            ],
            labelColor: AppTheme.primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Directory Search Results
                BlocBuilder<DirectoryBloc, DirectoryState>(
                  builder: (context, state) {
                    if (state is DirectoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DirectorySearchResults) {
                      return ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final entry = state.results[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(entry.name),
                            subtitle: Text(entry.title),
                            onTap: () {
                              // Navigate to directory entry details
                              Navigator.of(context).pushNamed(
                                AppRouter.directory,
                                arguments: entry.id,
                              );
                            },
                          );
                        },
                      );
                    } else if (state is DirectorySearchEmpty) {
                      return const Center(
                        child: Text('No directory results found'),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),

                // Dining Search Results
                BlocBuilder<DiningBloc, DiningState>(
                  builder: (context, state) {
                    if (state is DiningLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DiningSearchResults) {
                      final locationNames = state.results.keys.toList();
                      return ListView.builder(
                        itemCount: locationNames.length,
                        itemBuilder: (context, index) {
                          final location = locationNames[index];
                          final menuItems = state.results[location]!;

                          return ExpansionTile(
                            title: Text(location),
                            children: menuItems.map((item) {
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Text(item.description),
                                trailing:
                                    Text('\$${item.price.toStringAsFixed(2)}'),
                                onTap: () {
                                  // Navigate to dining details
                                },
                              );
                            }).toList(),
                          );
                        },
                      );
                    } else if (state is DiningSearchEmpty) {
                      return const Center(
                        child: Text('No menu items found'),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),

                // Locations Search Results
                BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    if (state is MapLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MapSearchResults) {
                      return ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final location = state.results[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.location_on),
                            ),
                            title: Text(location.name),
                            subtitle: Text(location.description),
                            onTap: () {
                              // Navigate to map and show this location
                              Navigator.of(context).pushNamed(
                                AppRouter.map,
                                arguments: location.id,
                              );
                            },
                          );
                        },
                      );
                    } else if (state is MapSearchEmpty) {
                      return const Center(
                        child: Text('No locations found'),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Could show recent searches or common search terms
    return const Center(
      child: Text('Start typing to search'),
    );
  }
}
