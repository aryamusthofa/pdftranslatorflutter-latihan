import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lampu_provider.dart';
import 'utils/app_language.dart';

class LampuPage extends StatelessWidget {
  const LampuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Consumer<LampuProvider>(
      builder: (context, lampuProvider, child) {
        final isSwitched = lampuProvider.isSwitched;
        final intensity = lampuProvider.intensity;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLanguage.t(context, 'smart_control')),
            backgroundColor: colorScheme.surface,
            elevation: 0,
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.primaryContainer.withValues(alpha: 0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Kontainer Lampu dengan Efek Glow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSwitched 
                        ? Colors.yellow.withValues(alpha: 0.1 + (intensity * 0.2)) 
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                    boxShadow: isSwitched ? [
                      BoxShadow(
                        color: Colors.yellow.withValues(alpha: intensity * 0.6),
                        blurRadius: 60 * intensity,
                        spreadRadius: 20 * intensity,
                      ),
                    ] : [],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                       Icon(
                        Icons.lightbulb,
                        size: 120,
                        color: isSwitched ? Colors.yellow : colorScheme.outline,
                      ),
                      if (isSwitched)
                        Icon(
                          Icons.lightbulb_outline,
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                
                // Card Kontrol
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            isSwitched ? AppLanguage.t(context, 'lamp_active') : AppLanguage.t(context, 'lamp_inactive'),
                            style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold,
                              color: isSwitched ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isSwitched 
                              ? AppLanguage.t(context, 'lamp_desc_on') 
                              : AppLanguage.t(context, 'lamp_desc_off'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 30),
                          if (isSwitched) ...[
                            Text('${AppLanguage.t(context, 'intensity')}: ${(intensity * 100).toInt()}%'),
                            Slider(
                              value: intensity,
                              onChanged: (value) {
                                lampuProvider.setIntensity(value);
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          Transform.scale(
                            scale: 1.5,
                            child: Switch(
                              value: isSwitched,
                              activeThumbColor: Colors.yellow.shade700,
                              onChanged: (value) {
                                lampuProvider.toggleLamp(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
