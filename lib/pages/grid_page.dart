//grid_page.dart


import 'package:flutter/material.dart';

class GridDemoPage extends StatelessWidget {
  const GridDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Data dummy untuk GridView.builder (Kategori)
    final List<Map<String, dynamic>> categories = [
      {'name': 'Elektronik', 'icon': Icons.tv, 'color': Colors.blue},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
      {'name': 'Makanan', 'icon': Icons.fastfood, 'color': Colors.orange},
      {'name': 'Olahraga', 'icon': Icons.fitness_center, 'color': Colors.green},
      {'name': 'Otomotif', 'icon': Icons.directions_car, 'color': Colors.purple},
      {'name': 'Buku', 'icon': Icons.book, 'color': Colors.brown},
    ];

    // 2. Data dummy untuk Katalog Produk (Visual)
    final List<Map<String, String>> products = [
      {
        'name': 'Kamera DSLR',
        'image': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
        'price': 'Rp 5.000.000'
      },
      {
        'name': 'Headphone Wireless',
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
        'price': 'Rp 1.200.000'
      },
      {
        'name': 'Jam Tangan Digital',
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
        'price': 'Rp 850.000'
      },
      {
        'name': 'Sepatu Sport',
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
        'price': 'Rp 1.500.000'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktek GridView Flutter'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN 1: GRIDVIEW.COUNT (MENU DASHBOARD)
            const Text(
              '1. GridView.count (Statis)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Menentukan jumlah kolom tetap secara manual.'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildMenuBox('Home', Icons.home, Colors.teal),
                _buildMenuBox('Chat', Icons.chat, Colors.blue),
                _buildMenuBox('Map', Icons.map, Colors.red),
                _buildMenuBox('Notif', Icons.notifications, Colors.amber),
                _buildMenuBox('Cari', Icons.search, Colors.indigo),
                _buildMenuBox('Set', Icons.settings, Colors.grey),
              ],
            ),

            const SizedBox(height: 30),

            // BAGIAN 2: GRIDVIEW.BUILDER (KATEGORI)
            const Text(
              '2. GridView.builder (Dinamis)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Efisien untuk data dari List atau API.'),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5, // Rasio lebar dibanding tinggi
              ),
              itemBuilder: (context, index) {
                final item = categories[index];
                return Card(
                  color: Colors.black.withValues(alpha: 0.2), // Changed from item['color'].withValues(alpha: 0.1)
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: item['color']),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'], color: item['color']),
                        const SizedBox(width: 8),
                        Text(
                          item['name'],
                          style: TextStyle(
                            color: item['color'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // BAGIAN 3: GRIDVIEW VISUAL (KATALOG PRODUK)
            const Text(
              '3. GridView Visual (Katalog Card)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Tampilan estetik dengan gambar dan bayangan.'),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75, // Membuat card lebih tinggi
              ),
              itemBuilder: (context, index) {
                return _buildImageCard(
                  products[index]['name']!,
                  products[index]['image']!,
                  products[index]['price']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // HELPER 1: Kotak Menu Sederhana
  Widget _buildMenuBox(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // HELPER 2: Card Visual dengan Gambar
  Widget _buildImageCard(String title, String imageUrl, String price) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}