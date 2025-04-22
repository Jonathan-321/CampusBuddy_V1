import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes.dart';
import '../../config/theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? bottom;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.bottom,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions ??
          [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return IconButton(
                    icon: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      backgroundImage: state.user.photoUrl != null
                          ? NetworkImage(state.user.photoUrl!)
                          : null,
                      child: state.user.photoUrl == null
                          ? Text(
                              _getInitials(state.user.displayName ?? ''),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.profile);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: bottom!,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => bottom != null
      ? const Size.fromHeight(kToolbarHeight + 48.0)
      : const Size.fromHeight(kToolbarHeight);

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
}
