import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../domain/entities/dining_info.dart';

class DiningCard extends StatelessWidget {
  final DiningInfo diningInfo;
  final VoidCallback? onTap;

  const DiningCard({
    Key? key,
    required this.diningInfo,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOpen = _isCurrentlyOpen(diningInfo.hours);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dining Location Image or Placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: diningInfo.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(diningInfo.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: diningInfo.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    )
                  : null,
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Name and Open/Closed Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          diningInfo.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            color: isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location Address
                  Text(
                    diningInfo.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Hours Today
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Today: ${_getTodayHours(diningInfo.hours)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating and Meal Plan Indicator
                  Row(
                    children: [
                      if (diningInfo.rating != null) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${diningInfo.rating}/5.0',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (diningInfo.acceptsMealPlan)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Meal Plan',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCurrentlyOpen(List<DiningHours> hours) {
    final now = DateTime.now();
    final dayOfWeek = _getDayOfWeek(now.weekday);
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Find today's hours
    final todayHours = hours.firstWhere(
      (hour) => hour.day.toLowerCase() == dayOfWeek.toLowerCase(),
      orElse: () => DiningHours(
        day: dayOfWeek,
        openTime: '00:00',
        closeTime: '00:00',
        isClosed: true,
      ),
    );
    
    if (todayHours.isClosed) return false;
    
    // Check if current time is between open and close time
    return _isTimeInRange(currentTime, todayHours.openTime, todayHours.closeTime);
  }

  String _getTodayHours(List<DiningHours> hours) {
    final now = DateTime.now();
    final dayOfWeek = _getDayOfWeek(now.weekday);
    
    // Find today's hours
    final todayHours = hours.firstWhere(
      (hour) => hour.day.toLowerCase() == dayOfWeek.toLowerCase(),
      orElse: () => DiningHours(
        day: dayOfWeek,
        openTime: '00:00',
        closeTime: '00:00',
        isClosed: true,
      ),
    );
    
    return todayHours.formattedHours;
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  bool _isTimeInRange(String current, String open, String close) {
    // Handle case where dining place is open past midnight
    if (close.compareTo(open) < 0) {
      return current.compareTo(open) >= 0 || current.compareTo(close) <= 0;
    }
    
    return current.compareTo(open) >= 0 && current.compareTo(close) <= 0;
  }
}
