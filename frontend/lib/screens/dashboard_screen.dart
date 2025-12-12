import 'package:flutter/material.dart';
import 'package:wedspace/models/venue.dart';
import 'package:wedspace/services/api_service.dart';
import 'package:wedspace/widgets/venue_card.dart';
import 'package:wedspace/widgets/booking_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Venue> _venues = [];
  List<Venue> _filteredVenues = [];
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String _username = '';
  int _userId = 0;
  
  // Filter controllers
  TextEditingController _searchController = TextEditingController();
  double _minPrice = 0;
  double _maxPrice = 100000000;
  int _minCapacity = 0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVenues();
    _loadBookings();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _userId = prefs.getInt('userId') ?? 0;
    });
  }
  
  Future<void> _loadVenues() async {
    try {
      final venues = await ApiService.getVenues();
      print('DEBUG: Fetched ${venues.length} venues');
      for (var v in venues) {
        print('DEBUG: Venue -> id: ${v.id}, name: ${v.name}, facilities: ${v.facilities}');
      }

      setState(() {
        _venues = venues;
        _filteredVenues = venues;
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      print('DEBUG: Error loading venues: $e');
      print(stacktrace);
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Gagal memuat data venue');
    }
  }

  String formatCurrency(dynamic value) {
    double amount = 0;
    if (value != null) {
      if (value is num) {
        amount = value.toDouble();
      } else if (value is String) {
        amount = double.tryParse(value) ?? 0;
      }
    }
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  Future<void> _loadBookings() async {
    if (_userId == 0) {
      print('DEBUG: User ID belum tersedia, skip load bookings');
      return;
    }

    try {
      final bookings = await ApiService.getUserBookings(_userId);
      print('DEBUG: Fetched ${bookings.length} bookings');
      for (var b in bookings) {
        print('DEBUG: Booking -> venue_name: ${b['venue_name']}, status: ${b['booking_status']}');
      }

      setState(() {
        _bookings = bookings;
      });
    } catch (e, stacktrace) {
      print('DEBUG: Error loading bookings: $e');
      print(stacktrace);
    }
  }

  
  void _applyFilters() {
    setState(() {
      _filteredVenues = _venues.where((venue) {
        bool matchesPrice = venue.price >= _minPrice && venue.price <= _maxPrice;
        bool matchesCapacity = venue.capacity >= _minCapacity;
        bool matchesSearch = _searchController.text.isEmpty ||
            venue.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            venue.location.toLowerCase().contains(_searchController.text.toLowerCase());
        
        return matchesPrice && matchesCapacity && matchesSearch;
      }).toList();
    });
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Venue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Harga Minimum: Rp ${_minPrice.toStringAsFixed(0)}'),
                    Slider(
                      value: _minPrice,
                      min: 0,
                      max: 100000000,
                      divisions: 10,
                      label: 'Rp ${_minPrice.toStringAsFixed(0)}',
                      onChanged: (value) {
                        setState(() {
                          _minPrice = value;
                        });
                      },
                    ),
                    
                    Text('Harga Maksimum: Rp ${_maxPrice.toStringAsFixed(0)}'),
                    Slider(
                      value: _maxPrice,
                      min: 0,
                      max: 200000000,
                      divisions: 10,
                      label: 'Rp ${_maxPrice.toStringAsFixed(0)}',
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                        });
                      },
                    ),
                    
                    SizedBox(height: 16),
                    Text('Kapasitas Minimum: $_minCapacity orang'),
                    Slider(
                      value: _minCapacity.toDouble(),
                      min: 0,
                      max: 1000,
                      divisions: 10,
                      label: '$_minCapacity orang',
                      onChanged: (value) {
                        setState(() {
                          _minCapacity = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadVenues();
    await _loadBookings();
  }
  
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('WedSpace - Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Refresh'),
                  value: 'refresh',
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                ),
              ],
              onSelected: (value) {
                if (value == 'refresh') {
                  _refreshData();
                } else if (value == 'logout') {
                  _logout();
                }
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Venues', icon: Icon(Icons.location_city)),
              Tab(text: 'Bookings', icon: Icon(Icons.book)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Venues
            _buildVenuesTab(),
            
            // Tab 2: Bookings
            _buildBookingsTab(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVenuesTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari venue...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              ),
            ),
            onChanged: (value) {
              _applyFilters();
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: _filteredVenues.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada venue yang ditemukan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: _filteredVenues.length,
                          itemBuilder: (context, index) {
                            final venue = _filteredVenues[index];
                            return VenueCard(
                              venue: venue,
                              onBook: () {
                                _showBookingDialog(venue);
                              },
                              onViewDetail: () {
                                _showVenueDetail(venue);
                              },
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildBookingsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada booking',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                final venueName = booking['venue_name'];
                final status = booking['booking_status'];
                final totalPrice = booking['total_price'];
                final dpAmount = booking['dp_amount'];
                final bookingDate = booking['booking_date'];
                final paymentStatus = booking['payment_status'];
                
                Color statusColor;
                switch (status) {
                  case 'confirmed':
                    statusColor = Colors.green;
                    break;
                  case 'pending':
                    statusColor = Colors.orange;
                    break;
                  case 'cancelled':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }
                
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Icon(
                        _getStatusIcon(status),
                        color: statusColor,
                      ),
                    ),
                    title: Text(venueName ?? 'Unknown Venue'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: $bookingDate'),
                        Text('Total: ${formatCurrency(booking['total_price'])}'),
                        Text('DP 50%: ${formatCurrency(booking['dp_amount'])}'),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: paymentStatus == 'paid' 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                paymentStatus?.toUpperCase() ?? 'PENDING',
                                style: TextStyle(
                                  color: paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      _showBookingDetail(booking);
                    },
                  ),
                );
              },
            ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  void _showVenueDetail(Venue venue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(venue.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(venue.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                venue.description,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16),
                  SizedBox(width: 4),
                  Text(venue.location),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16),
                  SizedBox(width: 4),
                  Text('${venue.capacity} orang'),
                ],
              ),
              SizedBox(height: 8),
              Text(
                venue.formattedPrice,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Fasilitas:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: venue.facilities.map((facility) {
                  return Chip(
                    label: Text(facility),
                    backgroundColor: Colors.blue[50],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBookingDialog(venue);
            },
            child: Text('Booking Sekarang'),
          ),
        ],
      ),
    );
  }
  
  void _showBookingDialog(Venue venue) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        venue: venue,
        userId: _userId,
        onBookingSuccess: () {
          _refreshData();
        },
      ),
    );
  }
  
  void _showBookingDetail(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Booking'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.home_work),
                title: Text('Venue'),
                subtitle: Text(booking['venue_name'] ?? ''),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Tanggal Booking'),
                subtitle: Text(booking['booking_date'] ?? ''),
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Total Harga'),
                subtitle: Text(formatCurrency(booking['total_price'])),
              ),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('DP 50%'),
                subtitle: Text(formatCurrency(booking['dp_amount'])),
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Status Booking'),
                subtitle: Text(booking['booking_status']?.toUpperCase() ?? ''),
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Status Pembayaran'),
                subtitle: Text(booking['payment_status']?.toUpperCase() ?? ''),
              ),
              if (booking['qris_image_url'] != null)
                Column(
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'QRIS untuk Pembayaran:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Image.network(
                      booking['qris_image_url'],
                      height: 200,
                      width: 200,
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}