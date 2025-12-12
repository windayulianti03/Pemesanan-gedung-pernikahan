-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 12 Des 2025 pada 18.34
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `wedspace_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `venue_id` int(11) NOT NULL,
  `booking_date` date NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `dp_amount` decimal(10,2) NOT NULL,
  `qris_image_url` varchar(500) DEFAULT NULL,
  `payment_status` enum('pending','paid','cancelled') DEFAULT 'pending',
  `booking_status` enum('pending','confirmed','completed','cancelled') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `venue_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `reviews`
--

INSERT INTO `reviews` (`id`, `user_id`, `venue_id`, `rating`, `comment`, `created_at`) VALUES
(1, 1, 1, 5, 'Tempatnya sangat megah dan pelayanan memuaskan!', '2025-12-12 16:16:20'),
(2, 1, 3, 4, 'View pantai luar biasa, hanya sedikit jauh dari kota', '2025-12-12 16:16:20');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `whatsapp` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `whatsapp`, `created_at`) VALUES
(1, 'winda', '123456', '+6281234567890', '2025-12-12 16:16:20');

-- --------------------------------------------------------

--
-- Struktur dari tabel `venues`
--

CREATE TABLE `venues` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `capacity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `location` varchar(200) DEFAULT NULL,
  `facilities` text DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT 0.00,
  `image_url` varchar(500) DEFAULT NULL,
  `is_booked` tinyint(1) DEFAULT 0,
  `booked_until` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `venues`
--

INSERT INTO `venues` (`id`, `name`, `description`, `capacity`, `price`, `location`, `facilities`, `rating`, `image_url`, `is_booked`, `booked_until`, `created_at`) VALUES
(1, 'Grand Ballroom Palace', 'Venue mewah dengan kapasitas besar dan dekorasi elegan', 500, 75000000.00, 'Jakarta Pusat', '[\"AC\", \"Panggung\", \"Sound System\", \"Catering\", \"Dekorasi\", \"Parkir Luas\"]', 4.50, 'https://example.com/venue1.jpg', 1, NULL, '2025-12-12 16:16:20'),
(2, 'Garden Wedding Resort', 'Venue outdoor dengan taman tropis yang indah', 300, 50000000.00, 'Bogor', '[\"Taman\", \"Kolam Renang\", \"Ruang Ganti\", \"Catering\", \"Dekorasi Alam\"]', 4.20, 'https://example.com/venue2.jpg', 0, NULL, '2025-12-12 16:16:20'),
(3, 'Intimate Beach Venue', 'Venue pinggir pantai untuk pernikahan romantis', 150, 35000000.00, 'Bali', '[\"Akses Pantai\", \"Gazebo\", \"Sound System\", Sunset View\", \"Catering Seafood\"]', 4.80, 'https://example.com/venue3.jpg', 1, NULL, '2025-12-12 16:16:20'),
(4, 'Modern Rooftop Hall', 'Venue modern dengan view kota dari ketinggian', 200, 45000000.00, 'Surabaya', '[\"AC\", \"View Kota\", \"LED Screen\", \"Bar\", \"Catering International\"]', 4.30, 'https://example.com/venue4.jpg', 0, NULL, '2025-12-12 16:16:20'),
(5, 'Traditional Joglo Venue', 'Venue tradisional Jawa dengan sentuhan modern', 250, 30000000.00, 'Yogyakarta', '[\"Joglo Asli\", \"Gamelan\", \"Taman Tradisional\", \"Catering Jawa\", \"Parkir\"]', 4.60, 'https://example.com/venue5.jpg', 1, NULL, '2025-12-12 16:16:20');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `venue_id` (`venue_id`);

--
-- Indeks untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `venue_id` (`venue_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indeks untuk tabel `venues`
--
ALTER TABLE `venues`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `venues`
--
ALTER TABLE `venues`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`);

--
-- Ketidakleluasaan untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
