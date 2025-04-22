import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../blocs/directory/directory_bloc.dart';
import '../blocs/directory/directory_event.dart';
import '../blocs/directory/directory_state.dart';
import '../widgets/directory_list_item.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' as error_widget;

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load directory entries and departments
    context.read<DirectoryBloc>().add(LoadAllDirectoryEntries());
    context.read<DirectoryBloc>().add(LoadAllDepartments());
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      
      if (_searchQuery.isNotEmpty) {
        context.read<DirectoryBloc>().add(SearchDirectoryEntries(_searchQuery));
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
        title: const Text('Campus Directory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Departments'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DirectoryBloc>().add(RefreshDirectoryEntries());
              context.read<DirectoryBloc>().add(LoadAllDepartments());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, department, or title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<DirectoryBloc>().add(LoadAllDirectoryEntries());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Directory Tab
                _buildAllDirectoryTab(),
                
                // Departments Tab
                _buildDepartmentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDirectoryTab() {
    return BlocBuilder<DirectoryBloc, DirectoryState>(
      builder: (context, state) {
        if (state is DirectoryLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is DirectoryEntriesLoaded) {
          return _buildDirectoryList(state.entries);
        } else if (state is DirectorySearchResults) {
          return _buildDirectoryList(state.results);
        } else if (state is DirectorySearchEmpty) {
          return Center(
            child: Text('No results found for "${state.query}"'),
          );
        } else if (state is DirectoryError) {
          return error_widget.ErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<DirectoryBloc>().add(LoadAllDirectoryEntries());
            },
          );
        } else if (state is DirectoryEmpty) {
          return const Center(
            child: Text('No directory entries available.'),
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }

  Widget _buildDepartmentsTab() {
    return BlocBuilder<DirectoryBloc, DirectoryState>(
      builder: (context, state) {
        if (state is DepartmentsLoaded) {
          return Column(
            children: [
              // Department Dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedDepartment,
                  items: state.departments.map((department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                    if (value != null) {
                      context.read<DirectoryBloc>().add(LoadDirectoryEntriesByDepartment(value));
                    }
                  },
                ),
              ),
              
              // Department Members List
              Expanded(
                child: BlocBuilder<DirectoryBloc, DirectoryState>(
                  builder: (context, state) {
                    if (state is DirectoryEntriesByDepartmentLoaded) {
                      return _buildDirectoryList(state.entries);
                    } else if (_selectedDepartment == null) {
                      return const Center(
                        child: Text('Please select a department'),
                      );
                    } else if (state is DirectoryLoading) {
                      return const Center(child: LoadingIndicator());
                    } else if (state is DirectoryError) {
                      return error_widget.ErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (_selectedDepartment != null) {
                            context.read<DirectoryBloc>().add(
                                  LoadDirectoryEntriesByDepartment(_selectedDepartment!),
                                );
                          }
                        },
                      );
                    } else if (state is DirectoryEmpty) {
                      return const Center(
                        child: Text('No directory entries found for this department.'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        } else if (state is DirectoryLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is DirectoryError) {
          return error_widget.ErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<DirectoryBloc>().add(LoadAllDepartments());
            },
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }

  Widget _buildDirectoryList(List<dynamic> entries) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DirectoryBloc>().add(RefreshDirectoryEntries());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return DirectoryListItem(
            entry: entry,
            onTap: () {
              _showEntryDetailsDialog(context, entry);
            },
          );
        },
      ),
    );
  }

  void _showEntryDetailsDialog(BuildContext context, dynamic entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entry.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Title: ${entry.title}'),
                const SizedBox(height: 8),
                Text('Department: ${entry.department}'),
                const SizedBox(height: 8),
                Text('Email: ${entry.email}'),
                const SizedBox(height: 8),
                Text('Phone: ${entry.phoneNumber}'),
                if (entry.officeLocation != null) ...[
                  const SizedBox(height: 8),
                  Text('Office: ${entry.officeLocation}'),
                ],
                if (entry.researchInterests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Research Interests:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...entry.researchInterests.map((interest) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text('• $interest'),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => _launchEmail(entry.email),
              child: const Text('Email'),
            ),
            TextButton(
              onPressed: () => _makePhoneCall(entry.phoneNumber),
              child: const Text('Call'),
            ),
          ],
        );
      },
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email to $email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone call to $phoneNumber'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
