import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../../domain/entities/user.dart';

class CustomDrawer extends StatelessWidget {
  final User user;

  const CustomDrawer({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildMenuItem(
            context,
            title: 'Home',
            icon: Icons.home,
            route: AppRouter.home,
          ),
          _buildMenuItem(
            context,
            title: 'Emergency Contacts',
            icon: Icons.emergency,
            route: AppRouter.emergency,
          ),
          _buildMenuItem(
            context,
            title: 'Campus Directory',
            icon: Icons.people,
            route: AppRouter.directory,
          ),
          _buildMenuItem(
            context,
            title: 'Dining',
            icon: Icons.restaurant,
            route: AppRouter.dining,
          ),
          _buildMenuItem(
            context,
            title: 'Events',
            icon: Icons.event,
            route: AppRouter.events,
          ),
          _buildMenuItem(
            context,
            title: 'Campus Map',
            icon: Icons.map,
            route: AppRouter.map,
          ),
          const Divider(),
          _buildMenuItem(
            context,
            title: 'My Profile',
            icon: Icons.person,
            route: AppRouter.profile,
          ),
          _buildMenuItem(
            context,
            title: 'Settings',
            icon: Icons.settings,
            onTap: () {
              // Navigate to settings screen
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            title: 'Help & Feedback',
            icon: Icons.help,
            onTap: () {
              // Navigate to help screen
            },
          ),
          _buildMenuItem(
            context,
            title: 'Sign Out',
            icon: Icons.logout,
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
      ),
      accountName: Text(
        user.displayName ?? 'Campus Student',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(user.email),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: user.photoUrl != null
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null
            ? Text(
                _getInitials(user.displayName ?? ''),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              )
            : null,
      ),
      otherAccountsPictures: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.school,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap ??
          () {
            Navigator.pop(context); // Close drawer
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    List<String> nameSplit = name.split(" ");
    String initials = "";
    
    if (nameSplit.isNotEmpty) {
      initials += nameSplit[0][0];
      if (nameSplit.length > 1) {
        initials += nameSplit[nameSplit.length - 1][0];
      }
    }
    return initials.toUpperCase();
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
