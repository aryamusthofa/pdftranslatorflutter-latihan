import 'package:flutter/material.dart';

class LampuPage extends StatefulWidget {
  const LampuPage({super.key});

  @override
  State<LampuPage> createState() => _LampuPageState();
}

class _LampuPageState extends State<LampuPage> {
  bool _isLampOn = false;

  void _toggleSwitch() {
    setState(() {
      _isLampOn = !_isLampOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan State (Lampu)'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 150,
              color: _isLampOn ? Colors.yellow : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isLampOn ? 'LAMPU MENYALA (ON)' : 'LAMPU MATI (OFF)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleSwitch,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLampOn ? Colors.red : Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                _isLampOn ? 'Matikan Lampu' : 'Nyalakan Lampu',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
