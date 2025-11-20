import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scada_crossplatform/src/app.dart';

void main() {
  // Platform-specific initialization for desktop
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                  defaultTargetPlatform == TargetPlatform.linux || 
                  defaultTargetPlatform == TargetPlatform.macOS)) {
    // Initialize desktop-specific settings
  }
  
  runApp(
    const ProviderScope(
      child: ScadaApp(),
    ),
  );
}