import 'package:flutter/material.dart';
import 'package:wedspace/models/venue.dart';
import 'package:wedspace/services/api_service.dart';
import 'package:intl/intl.dart';

class BookingDialog extends StatefulWidget {
  final Venue venue;
  final int userId;
  final VoidCallback onBookingSuccess;
  
  const BookingDialog({
    Key? key,
    required this.venue,
    required this.userId,
    required this.onBookingSuccess,
  }) : super(key: key);
  
  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  bool _isBooking = false;
  String _errorMessage = '';
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2025, 12, 31),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Pilih tanggal booking terlebih dahulu';
      });
      return;
    }
    
    setState(() {
      _isBooking = true;
      _errorMessage = '';
    });
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      
      final response = await ApiService.createBooking(
        widget.userId,
        widget.venue.id,
        dateStr,
      );
      
      if (response['error'] != null) {
        throw Exception(response['error']);
      }
      
      Navigator.pop(context);
      widget.onBookingSuccess();
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Booking Berhasil!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Booking venue ${widget.venue.name} berhasil dibuat.'),
              SizedBox(height: 16),
              Text(
                'DP 50%: ${widget.venue.formattedPrice}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text('Silakan lakukan pembayaran melalui QRIS yang tersedia.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double dpAmount = widget.venue.price * 0.5;
    
    return AlertDialog(
      title: Text('Booking ${widget.venue.name}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.venue.description,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Kapasitas'),
                subtitle: Text('${widget.venue.capacity} orang'),
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Harga Total'),
                subtitle: Text(widget.venue.formattedPrice),
              ),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('DP 50%'),
                subtitle: Text(
                  'Rp ${dpAmount.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  )}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!), // <- tambahkan !
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: _errorMessage.isNotEmpty ? 16 : 0),
              
              Text(
                'Pilih Tanggal Booking:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Color(0xFF6A11CB)),
                      SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                            : 'Pilih tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        _isBooking
        ? ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A11CB), // <- ganti dari primary
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
        : ElevatedButton(
            onPressed: _submitBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A11CB), // <- ganti dari primary
            ),
            child: Text('Konfirmasi Booking'),
          ),
      ],
    );
  }
}