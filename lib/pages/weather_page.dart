import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class WeatherPage extends StatefulWidget {
  final String username;
  const WeatherPage({super.key, required this.username});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic>? weatherData;

  String selectedCity = 'Jakarta';

  final Map<String, Map<String, double>> cities = {
    'Jakarta': {'lat': -6.2088, 'lon': 106.8456},
    'Semarang': {'lat': -6.9932, 'lon': 110.4203},
    'Yogyakarta': {'lat': -7.7956, 'lon': 110.3695},
    'Wonosobo': {'lat': -7.3647, 'lon': 109.9019},
    'Bandung': {'lat': -6.9147, 'lon': 107.6098},
    'Surabaya': {'lat': -7.2504, 'lon': 112.7688},
    'Malang': {'lat': -7.9839, 'lon': 112.6214},
    'Denpasar': {'lat': -8.6500, 'lon': 115.2167},
  };

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      // Menambahkan parameter 'daily' untuk mengambil prediksi cuaca 7 hari ke depan
      double lat = cities[selectedCity]!['lat']!;
      double lon = cities[selectedCity]!['lon']!;
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Asia%2FJakarta');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal mengambil data cuaca dari server.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan jaringan: $e';
        isLoading = false;
      });
    }
  }

  // Fungsi untuk menerjemahkan kode cuaca menjadi teks (Sudah Dilengkapi)
  String getWeatherDescription(int code) {
    switch (code) {
      case 0: return 'Cerah';
      case 1: case 2: return 'Cerah Berawan';
      case 3: return 'Mendung';
      case 45: case 48: return 'Berkabut';
      case 51: case 53: case 55: return 'Gerimis';
      case 56: case 57: return 'Gerimis Dingin';
      case 61: case 63: case 65: return 'Hujan';
      case 66: case 67: return 'Hujan Dingin';
      case 71: case 73: case 75: case 77: return 'Bersalju';
      case 80: case 81: case 82: return 'Hujan Deras'; // Sering terjadi di Jakarta
      case 85: case 86: return 'Hujan Salju';
      case 95: case 96: case 99: return 'Badai Petir'; // Sering terjadi di Jakarta
      default: return 'Lainnya ($code)';
    }
  }

  // Fungsi untuk menerjemahkan kode cuaca menjadi Icon (Sudah Dilengkapi)
  IconData getWeatherIcon(int code) {
    switch (code) {
      case 0: return Icons.wb_sunny;
      case 1: case 2: return Icons.cloud_queue; // Icon awan cerah
      case 3: return Icons.cloud; // Icon awan mendung
      case 45: case 48: return Icons.foggy;
      case 51: case 53: case 55: return Icons.grain; // Icon rintik gerimis
      case 56: case 57: return Icons.ac_unit;
      case 61: case 63: case 65: return Icons.water_drop;
      case 66: case 67: return Icons.ac_unit;
      case 71: case 73: case 75: case 77: return Icons.ac_unit;
      case 80: case 81: case 82: return Icons.thunderstorm; // Icon hujan deras/badai
      case 85: case 86: return Icons.ac_unit;
      case 95: case 96: case 99: return Icons.flash_on; // Icon petir
      default: return Icons.help_outline;
    }
  }

  // Fungsi untuk mendapatkan nama hari dari format tanggal API (YYYY-MM-DD)
  String getDayName(String dateString) {
    DateTime date = DateTime.parse(dateString);
    List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan extendBodyBehindAppBar agar gradient background menyatu dengan AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Cuaca $selectedCity', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Menambahkan Gradient Background agar terlihat modern
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.lightBlue.shade200],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Mempertahankan Username
                            Text(
                              'Halo, ${widget.username}!',
                              style: const TextStyle(fontSize: 18, color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            
                            // INFO LOKASI
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, size: 28, color: Colors.white),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: selectedCity,
                                  dropdownColor: Colors.blue.shade900,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                  underline: const SizedBox(),
                                  items: cities.keys.map((String city) {
                                    return DropdownMenuItem<String>(
                                      value: city,
                                      child: Text('$city, Indonesia'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newCity) {
                                    if (newCity != null) {
                                      setState(() {
                                        selectedCity = newCity;
                                        isLoading = true;
                                      });
                                      fetchWeatherData();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // CARD CUACA SAAT INI
                            if (weatherData != null && weatherData!['current'] != null)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      getWeatherIcon(weatherData!['current']['weather_code']),
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${weatherData!['current']['temperature_2m']}°C',
                                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      getWeatherDescription(weatherData!['current']['weather_code']),
                                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 20),
                                    const Divider(color: Colors.white54),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildWeatherDetail(
                                          Icons.water_drop, 
                                          'Kelembapan', 
                                          '${weatherData!['current']['relative_humidity_2m']}%'
                                        ),
                                        _buildWeatherDetail(
                                          Icons.air, 
                                          'Angin', 
                                          '${weatherData!['current']['wind_speed_10m']} km/h'
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(height: 40),

                            // SECTION PREDIKSI 7 HARI KE DEPAN
                            if (weatherData != null && weatherData!['daily'] != null) ...[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Prediksi 7 Hari Ke Depan',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: weatherData!['daily']['time'].length,
                                  itemBuilder: (context, index) {
                                    return _buildDailyForecastCard(
                                      date: weatherData!['daily']['time'][index],
                                      weatherCode: weatherData!['daily']['weather_code'][index],
                                      maxTemp: weatherData!['daily']['temperature_2m_max'][index],
                                      minTemp: weatherData!['daily']['temperature_2m_min'][index],
                                    );
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),
                            
                            // Mempertahankan fitur tombol Logout dari code sebelumnya
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.logout),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  // Widget helper untuk detail cuaca (Kelembapan & Angin)
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Widget helper untuk card prediksi harian
  Widget _buildDailyForecastCard({
    required String date,
    required int weatherCode,
    required double maxTemp,
    required double minTemp,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getDayName(date),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            date.substring(5), // Mengambil MM-DD saja
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Icon(
            getWeatherIcon(weatherCode),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${maxTemp.round()}°',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                '${minTemp.round()}°',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
