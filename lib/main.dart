import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:pokey_music/bloc/login_bloc.dart';
import 'package:pokey_music/handler/audio_handler.dart';
import 'package:pokey_music/repository/auth_repository.dart';
import 'package:pokey_music/ui/login_screen.dart';

import 'bloc/player_bloc.dart';
import 'ui/player_screen.dart';
import 'utils/token_storage.dart';

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

  // Verificar si hay token
  final token = await TokenStorage.getToken();

  runApp(MyApp(audioHandler: audioHandler, token: token));
}

class MyApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final String? token;

  const MyApp({super.key, required this.audioHandler, required this.token});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PlayerBloc(audioHandler)),
        BlocProvider(create: (_) => LoginBloc(AuthRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
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
        home: token != null ? const PlayerScreen() : LoginScreen(),
      ),
    );
  }
}
