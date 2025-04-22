import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset the form
        _displayNameController.text = '';
        _imageFile = null;
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement profile update in AuthBloc
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _signOut() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is Authenticated) {
            final user = state.user;

            if (!_isEditing) {
              // Display Profile
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user.displayName ?? 'Campus Student',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 8),

                    // Email
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Verification Status
                    if (user.isEmailVerified)
                      _buildInfoRow(
                        icon: Icons.verified_user,
                        text: 'Email Verified',
                        iconColor: Colors.green,
                      )
                    else
                      _buildInfoRow(
                        icon: Icons.error_outline,
                        text: 'Email Not Verified - Verify Now',
                        iconColor: Colors.orange,
                        onTap: () {
                          // TODO: Implement email verification
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Verification email sent. Please check your inbox.'),
                            ),
                          );
                        },
                      ),

                    const Divider(height: 32),

                    // Settings Sections
                    _buildSettingsSection(
                      title: 'Account Settings',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.password,
                          title: 'Change Password',
                          onTap: () {
                            // Navigate to change password screen
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.notifications,
                          title: 'Notification Preferences',
                          onTap: () {
                            // Navigate to notifications settings
                          },
                        ),
                      ],
                    ),

                    _buildSettingsSection(
                      title: 'App Settings',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: false, // TODO: Use actual theme state
                            onChanged: (value) {
                              // TODO: Toggle theme
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ),
                        _buildSettingsItem(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {
                            // Navigate to language settings
                          },
                        ),
                      ],
                    ),

                    _buildSettingsSection(
                      title: 'Support',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {
                            // Navigate to help screen
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {
                            // Navigate to privacy policy
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {
                            // Show about dialog
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sign Out Button
                    ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Edit Profile Form
              if (_displayNameController.text.isEmpty) {
                _displayNameController.text = user.displayName ?? '';
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image Picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : user.photoUrl != null
                                      ? NetworkImage(user.photoUrl!)
                                          as ImageProvider
                                      : null,
                              child:
                                  (_imageFile == null && user.photoUrl == null)
                                      ? const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Display Name Field
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email Field (read-only)
                      TextFormField(
                        initialValue: user.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        readOnly: true,
                        enabled: false,
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          return const Center(
            child: Text('Please sign in to view your profile'),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Text(text),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: row,
      );
    }

    return row;
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: items,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
