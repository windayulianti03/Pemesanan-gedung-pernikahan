import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wedspace/models/venue.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.11:5000/api';
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Register
  static Future<Map<String, dynamic>> register(String username, String password, String whatsapp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'whatsapp': whatsapp,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get venues with optional filters
  static Future<List<Venue>> getVenues({
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
    String? location,
  }) async {
    String url = '$baseUrl/venues';
    List<String> params = [];
    
    if (minPrice != null) params.add('min_price=$minPrice');
    if (maxPrice != null) params.add('max_price=$maxPrice');
    if (minCapacity != null) params.add('min_capacity=$minCapacity');
    if (location != null && location.isNotEmpty) params.add('location=$location');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Venue.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load venues');
    }
  }
  
  // Get venue detail
  static Future<Map<String, dynamic>> getVenueDetail(int venueId) async {
    final response = await http.get(Uri.parse('$baseUrl/venues/$venueId'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load venue detail');
    }
  }
  
  // Create booking
  static Future<Map<String, dynamic>> createBooking(
    int userId, 
    int venueId, 
    String bookingDate,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'venue_id': venueId,
        'booking_date': bookingDate,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get user bookings
  static Future<List<dynamic>> getUserBookings(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings/user/$userId'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}