import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:pokey_music/handler/audio_handler.dart';

import 'bloc/player_bloc.dart';
import 'ui/player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Iniciar AudioService
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.pokey_music.channel.audio',
      androidNotificationChannelName: 'Reproducción de música',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 👈 Oculta el banner de debug
      themeMode: ThemeMode.system, // 👈 Sigue el modo del sistema
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: BlocProvider(
        create: (_) => PlayerBloc(audioHandler),
        child: const PlayerScreen(),
      ),
    );
  }
}
