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
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.audio.channel',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
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
      home: BlocProvider(
        create: (_) => PlayerBloc(audioHandler),
        child: const PlayerScreen(),
      ),
    );
  }
}
