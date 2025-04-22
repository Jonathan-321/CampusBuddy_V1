import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../blocs/emergency/emergency_bloc.dart';
import '../blocs/emergency/emergency_event.dart';
import '../blocs/emergency/emergency_state.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' as error_widget;

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<EmergencyBloc>().add(LoadEmergencyContacts());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _makeEmergencyCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Emergency'),
            Tab(text: 'Residence Assistants'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EmergencyBloc>().add(RefreshEmergencyContacts());
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Emergency Contacts Tab
          BlocBuilder<EmergencyBloc, EmergencyState>(
            builder: (context, state) {
              if (state is EmergencyLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is EmergencyLoaded) {
                return _buildEmergencyContactsList(state);
              } else if (state is EmergencyError) {
                return error_widget.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<EmergencyBloc>().add(LoadEmergencyContacts());
                  },
                );
              } else if (state is EmergencyEmpty) {
                return const Center(
                  child: Text('No emergency contacts available.'),
                );
              }
              return const Center(child: LoadingIndicator());
            },
          ),

          // Residence Assistants Tab
          _buildResidenceAssistantsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _makeEmergencyCall('911'),
        icon: const Icon(Icons.phone),
        label: const Text('EMERGENCY CALL'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildEmergencyContactsList(EmergencyLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildEmergencyBanner(),
        const SizedBox(height: 16),

        // Campus Police Card (Highlighted)
        _buildPriorityContactCard(
          title: 'Campus Police',
          phoneNumber: '(555) 123-4567',
          description: 'Available 24/7 for emergency situations on campus',
          icon: Icons.local_police,
          color: Colors.blue,
          isEmergency: true,
        ),

        const SizedBox(height: 16),

        // Health Center Card
        _buildPriorityContactCard(
          title: 'Student Health Center',
          phoneNumber: '(555) 987-6543',
          description: 'Medical services and mental health support',
          icon: Icons.local_hospital,
          color: Colors.green,
          isEmergency: false,
        ),

        const SizedBox(height: 24),

        const Text(
          'Other Emergency Contacts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // List of other emergency contacts
        ...state.allContacts
            .map((contact) => EmergencyContactCard(contact: contact))
            .toList(),
      ],
    );
  }

  Widget _buildResidenceAssistantsTab() {
    // This would ideally be populated from a database or API
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildResidenceHeader('North Campus'),
        _buildRACard(
          name: 'Alex Johnson',
          building: 'North Hall',
          floor: '1st Floor',
          phoneNumber: '(555) 111-2222',
          email: 'alex.johnson@university.edu',
          imageUrl: null,
        ),
        _buildRACard(
          name: 'Jamie Smith',
          building: 'North Hall',
          floor: '2nd Floor',
          phoneNumber: '(555) 222-3333',
          email: 'jamie.smith@university.edu',
          imageUrl: null,
        ),
        _buildResidenceHeader('South Campus'),
        _buildRACard(
          name: 'Taylor Williams',
          building: 'South Hall',
          floor: '1st Floor',
          phoneNumber: '(555) 333-4444',
          email: 'taylor.williams@university.edu',
          imageUrl: null,
        ),
        _buildRACard(
          name: 'Jordan Miller',
          building: 'South Hall',
          floor: '2nd Floor',
          phoneNumber: '(555) 444-5555',
          email: 'jordan.miller@university.edu',
          imageUrl: null,
        ),
        _buildResidenceHeader('East Campus'),
        _buildRACard(
          name: 'Casey Brown',
          building: 'East Hall',
          floor: '1st Floor',
          phoneNumber: '(555) 555-6666',
          email: 'casey.brown@university.edu',
          imageUrl: null,
        ),
        _buildResidenceHeader('West Campus'),
        _buildRACard(
          name: 'Riley Davis',
          building: 'West Hall',
          floor: '1st Floor',
          phoneNumber: '(555) 666-7777',
          email: 'riley.davis@university.edu',
          imageUrl: null,
        ),
      ],
    );
  }

  Widget _buildResidenceHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildRACard({
    required String name,
    required String building,
    required String floor,
    required String phoneNumber,
    required String email,
    String? imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // RA Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.withOpacity(0.1),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 30, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 16),

            // RA Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$building, $floor',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
                  icon: const Icon(Icons.phone),
                  color: Colors.blue,
                  onPressed: () => _makeEmergencyCall(phoneNumber),
                  tooltip: 'Call',
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  color: Colors.blue,
                  onPressed: () {
                    // Launch email
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: email,
                    );
                    launchUrl(emailUri);
                  },
                  tooltip: 'Email',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityContactCard({
    required String title,
    required String phoneNumber,
    required String description,
    required IconData icon,
    required Color color,
    required bool isEmergency,
  }) {
    return Card(
      elevation: isEmergency ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isEmergency
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          color: isEmergency ? Colors.red : Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Text'),
                  onPressed: () {
                    // Launch SMS
                    final Uri smsUri = Uri(
                      scheme: 'sms',
                      path: phoneNumber,
                    );
                    launchUrl(smsUri);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isEmergency ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  onPressed: () => _makeEmergencyCall(phoneNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmergency ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'In Case of Emergency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'If you need immediate assistance, call 911 or use the emergency button below.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _makeEmergencyCall('911'),
            icon: const Icon(Icons.phone),
            label: const Text('CALL 911'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
