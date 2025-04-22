import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../animations/animated_list_item.dart';

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> items;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsets padding;
  
  const QuickActionGrid({
    Key? key,
    required this.items,
    this.crossAxisCount = 4,
    this.spacing = 16.0,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.85, // Slightly taller than wide for better text display
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimatedListItem(
            index: index,
            duration: const Duration(milliseconds: 500),
            beginOffset: const Offset(0, 0.2),
            child: QuickActionTile(
              item: items[index],
            ),
          );
        },
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  final QuickActionItem item;
  
  const QuickActionTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTapContainer(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: item.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.iconColor?.withOpacity(0.7) ?? AppTheme.primaryColor.withOpacity(0.7),
                    item.iconColor ?? AppTheme.primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (item.iconColor ?? AppTheme.primaryColor).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            // Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Badge (if any)
            if (item.badgeCount != null && item.badgeCount! > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final int? badgeCount;
  final Color? badgeColor;
  final bool isNew;
  
  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.badgeCount,
    this.badgeColor,
    this.isNew = false,
  });
}

class QuickActionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final String? viewAllText;
  final Widget? trailing;
  
  const QuickActionHeader({
    Key? key,
    required this.title,
    this.onViewAll,
    this.viewAllText,
    this.trailing,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing ?? (onViewAll != null
            ? TextButton.icon(
                onPressed: onViewAll,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(viewAllText ?? 'View all'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            : const SizedBox()),
        ],
      ),
    );
  }
}
