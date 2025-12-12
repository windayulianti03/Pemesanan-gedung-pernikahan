import 'dart:convert';

class Venue {
  final int id;
  final String name;
  final String description;
  final int capacity;
  final double price;
  final String location;
  final List<String> facilities;
  final double rating;
  final String imageUrl;
  final bool isBooked;
  
  Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.price,
    required this.location,
    required this.facilities,
    required this.rating,
    required this.imageUrl,
    required this.isBooked,
  });
  
  factory Venue.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing venue JSON -> $json');

    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    List<String> parseFacilities(dynamic value) {
      if (value == null) return [];
      if (value is String && value.isNotEmpty) {
        try {
          return List<String>.from(jsonDecode(value));
        } catch (_) {
          return [];
        }
      }
      if (value is List) return List<String>.from(value);
      return [];
    }

    return Venue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 0,
      price: parseDouble(json['price']),
      location: json['location'] ?? '',
      facilities: parseFacilities(json['facilities']),
      rating: parseDouble(json['rating']),
      imageUrl: json['image_url'] ?? '',
      isBooked: (json['is_booked'] ?? 0) == 1,
    );
  }

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}