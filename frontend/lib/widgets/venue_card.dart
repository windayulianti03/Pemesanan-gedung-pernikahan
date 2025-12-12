import 'package:flutter/material.dart';
import 'package:wedspace/models/venue.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onBook;
  final VoidCallback onViewDetail;
  
  const VenueCard({
    Key? key,
    required this.venue,
    required this.onBook,
    required this.onViewDetail,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onViewDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      venue.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Icon(Icons.home_work, size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              venue.location,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '${venue.capacity} orang',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              venue.rating.toString(),
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                venue.description.length > 100
                    ? '${venue.description.substring(0, 100)}...'
                    : venue.description,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      venue.formattedPrice,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A11CB), // Ganti dari primary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Booking'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: venue.facilities.take(3).map((facility) {
                  return Chip(
                    label: Text(facility),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}