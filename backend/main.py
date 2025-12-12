from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import json
from decimal import Decimal
from datetime import datetime
import os
from config import config

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Database connection
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=config.MYSQL_HOST,
            user=config.MYSQL_USER,
            password=config.MYSQL_PASSWORD,
            database=config.MYSQL_DATABASE,
            port=config.MYSQL_PORT
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

# Helper function to convert Decimal to float for JSON serialization
def decimal_to_float(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

# User Routes
@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')  # Warning: Not hashed!
    whatsapp = data.get('whatsapp')
    
    if not all([username, password, whatsapp]):
        return jsonify({'error': 'Semua field harus diisi'}), 400
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor()
        
        # Check if username exists
        cursor.execute("SELECT id FROM users WHERE username = %s", (username,))
        if cursor.fetchone():
            return jsonify({'error': 'Username sudah digunakan'}), 400
        
        # Insert new user
        cursor.execute(
            "INSERT INTO users (username, password, whatsapp) VALUES (%s, %s, %s)",
            (username, password, whatsapp)
        )
        connection.commit()
        
        # Get the new user
        cursor.execute("SELECT id, username, whatsapp FROM users WHERE username = %s", (username,))
        user = cursor.fetchone()
        
        return jsonify({
            'message': 'Registrasi berhasil',
            'user': {
                'id': user[0],
                'username': user[1],
                'whatsapp': user[2]
            }
        }), 201
        
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    if not all([username, password]):
        return jsonify({'error': 'Username dan password harus diisi'}), 400
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        cursor.execute(
            "SELECT id, username, whatsapp FROM users WHERE username = %s AND password = %s",
            (username, password)
        )
        user = cursor.fetchone()
        
        if user:
            return jsonify({
                'message': 'Login berhasil',
                'user': user
            }), 200
        else:
            return jsonify({'error': 'Username atau password salah'}), 401
            
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

# Venue Routes
@app.route('/api/venues', methods=['GET'])
def get_venues():
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # Get query parameters for filtering
        min_price = request.args.get('min_price')
        max_price = request.args.get('max_price')
        min_capacity = request.args.get('min_capacity')
        location = request.args.get('location')
        
        query = "SELECT * FROM venues WHERE 1=1"
        params = []
        
        if min_price:
            query += " AND price >= %s"
            params.append(float(min_price))
        if max_price:
            query += " AND price <= %s"
            params.append(float(max_price))
        if min_capacity:
            query += " AND capacity >= %s"
            params.append(int(min_capacity))
        if location:
            query += " AND location LIKE %s"
            params.append(f"%{location}%")
        
        query += " ORDER BY rating DESC"
        
        cursor.execute(query, params)
        venues = cursor.fetchall()
        
        # Parse facilities JSON string
        for venue in venues:
            if venue['facilities']:
                try:
                    venue['facilities'] = json.loads(venue['facilities'])
                except:
                    venue['facilities'] = []
            else:
                venue['facilities'] = []
        
        return jsonify(venues), 200
        
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

@app.route('/api/venues/<int:venue_id>', methods=['GET'])
def get_venue_detail(venue_id):
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # Get venue details
        cursor.execute("SELECT * FROM venues WHERE id = %s", (venue_id,))
        venue = cursor.fetchone()
        
        if not venue:
            return jsonify({'error': 'Venue tidak ditemukan'}), 404
        
        # Parse facilities
        if venue['facilities']:
            try:
                venue['facilities'] = json.loads(venue['facilities'])
            except:
                venue['facilities'] = []
        else:
            venue['facilities'] = []
        
        # Get reviews for this venue
        cursor.execute("""
            SELECT r.*, u.username 
            FROM reviews r 
            JOIN users u ON r.user_id = u.id 
            WHERE r.venue_id = %s 
            ORDER BY r.created_at DESC
        """, (venue_id,))
        reviews = cursor.fetchall()
        
        venue['reviews'] = reviews
        
        return jsonify(venue), 200
        
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

# Booking Routes
@app.route('/api/bookings', methods=['POST'])
def create_booking():
    data = request.json
    user_id = data.get('user_id')
    venue_id = data.get('venue_id')
    booking_date = data.get('booking_date')
    
    if not all([user_id, venue_id, booking_date]):
        return jsonify({'error': 'Semua field harus diisi'}), 400
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        # Check venue availability
        cursor.execute("SELECT price, is_booked FROM venues WHERE id = %s", (venue_id,))
        venue = cursor.fetchone()
        
        if not venue:
            return jsonify({'error': 'Venue tidak ditemukan'}), 404
        
        if venue['is_booked']:
            return jsonify({'error': 'Venue sudah dibooking'}), 400
        
        # Calculate DP 50%
        total_price = venue['price']
        dp_amount = total_price * Decimal('0.5')
        
        # Create booking
        cursor.execute("""
            INSERT INTO bookings (user_id, venue_id, booking_date, total_price, dp_amount)
            VALUES (%s, %s, %s, %s, %s)
        """, (user_id, venue_id, booking_date, total_price, dp_amount))
        
        # Update venue status
        cursor.execute("UPDATE venues SET is_booked = TRUE WHERE id = %s", (venue_id,))
        
        connection.commit()
        
        # Get booking ID
        booking_id = cursor.lastrowid
        
        # Generate QRIS URL (simulasi)
        qris_url = f"https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=WEDSPACE-BOOKING-{booking_id}"
        
        # Update booking with QRIS URL
        cursor.execute("UPDATE bookings SET qris_image_url = %s WHERE id = %s", (qris_url, booking_id))
        
        cursor.execute("SELECT * FROM bookings WHERE id = %s", (booking_id,))
        booking = cursor.fetchone()
        
        return jsonify({
            'message': 'Booking berhasil dibuat',
            'booking': booking,
            'qris_url': qris_url
        }), 201
        
    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

@app.route('/api/bookings/user/<int:user_id>', methods=['GET'])
def get_user_bookings(user_id):
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        
        cursor.execute("""
            SELECT b.*, v.name as venue_name, v.image_url as venue_image
            FROM bookings b
            JOIN venues v ON b.venue_id = v.id
            WHERE b.user_id = %s
            ORDER BY b.created_at DESC
        """, (user_id,))
        
        bookings = cursor.fetchall()
        
        return jsonify(bookings), 200
        
    except Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

# Review Routes
@app.route('/api/reviews', methods=['POST'])
def create_review():
    data = request.json
    user_id = data.get('user_id')
    venue_id = data.get('venue_id')
    rating = data.get('rating')
    comment = data.get('comment', '')
    
    if not all([user_id, venue_id, rating]):
        return jsonify({'error': 'User, venue, dan rating harus diisi'}), 400
    
    if not (1 <= rating <= 5):
        return jsonify({'error': 'Rating harus antara 1-5'}), 400
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor()
        
        # Check if user has booked this venue
        cursor.execute("""
            SELECT id FROM bookings 
            WHERE user_id = %s AND venue_id = %s AND booking_status = 'completed'
        """, (user_id, venue_id))
        
        if not cursor.fetchone():
            return jsonify({'error': 'Hanya bisa mereview venue yang sudah digunakan'}), 400
        
        # Create review
        cursor.execute("""
            INSERT INTO reviews (user_id, venue_id, rating, comment)
            VALUES (%s, %s, %s, %s)
        """, (user_id, venue_id, rating, comment))
        
        # Update venue rating
        cursor.execute("""
            UPDATE venues 
            SET rating = (
                SELECT AVG(rating) 
                FROM reviews 
                WHERE venue_id = %s
            )
            WHERE id = %s
        """, (venue_id, venue_id))
        
        connection.commit()
        
        return jsonify({'message': 'Review berhasil ditambahkan'}), 201
        
    except Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        connection.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000, host='0.0.0.0')