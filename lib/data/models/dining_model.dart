import '../../domain/entities/dining_info.dart';

class DiningInfoModel extends DiningInfo {
  DiningInfoModel({
    required super.id,
    required super.name,
    required super.location,
    required super.description,
    required List<DiningHoursModel> super.hours,
    required List<MenuItemModel> super.menu,
    super.acceptsMealPlan,
    super.rating,
    super.imageUrl,
  });

  factory DiningInfoModel.fromJson(Map<String, dynamic> json) {
    return DiningInfoModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      hours: json['hours'] != null
          ? List<DiningHoursModel>.from(
              json['hours'].map((x) => DiningHoursModel.fromJson(x)))
          : [],
      menu: json['menu'] != null
          ? List<MenuItemModel>.from(
              json['menu'].map((x) => MenuItemModel.fromJson(x)))
          : [],
      acceptsMealPlan: json['acceptsMealPlan'] ?? false,
      rating: json['rating']?.toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'hours': (hours as List<DiningHoursModel>)
          .map((hour) => hour.toJson())
          .toList(),
      'menu':
          (menu as List<MenuItemModel>).map((item) => item.toJson()).toList(),
      'acceptsMealPlan': acceptsMealPlan,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }

  factory DiningInfoModel.fromEntity(DiningInfo info) {
    return DiningInfoModel(
      id: info.id,
      name: info.name,
      location: info.location,
      description: info.description,
      hours: info.hours
          .map((hour) => DiningHoursModel.fromEntity(hour))
          .toList(),
      menu: info.menu
          .map((item) => MenuItemModel.fromEntity(item))
          .toList(),
      acceptsMealPlan: info.acceptsMealPlan,
      rating: info.rating,
      imageUrl: info.imageUrl,
    );
  }
}

class DiningHoursModel extends DiningHours {
  DiningHoursModel({
    required super.day,
    required super.openTime,
    required super.closeTime,
    super.isClosed,
  });

  factory DiningHoursModel.fromJson(Map<String, dynamic> json) {
    return DiningHoursModel(
      day: json['day'] ?? '',
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      isClosed: json['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }

  factory DiningHoursModel.fromEntity(DiningHours hours) {
    return DiningHoursModel(
      day: hours.day,
      openTime: hours.openTime,
      closeTime: hours.closeTime,
      isClosed: hours.isClosed,
    );
  }
}

class MenuItemModel extends MenuItem {
  MenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.dietaryInfo,
    required super.category,
    super.isAvailable,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      dietaryInfo: json['dietaryInfo'] != null
          ? List<String>.from(json['dietaryInfo'])
          : [],
      category: json['category'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'dietaryInfo': dietaryInfo,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  factory MenuItemModel.fromEntity(MenuItem item) {
    return MenuItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      dietaryInfo: item.dietaryInfo,
      category: item.category,
      isAvailable: item.isAvailable,
    );
  }
}
