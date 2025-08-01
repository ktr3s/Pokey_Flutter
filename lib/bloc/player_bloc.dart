import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokey_music/handler/audio_handler.dart';

abstract class PlayerEvent {}

class PlayTrack extends PlayerEvent {
  final String url;
  final String title;
  final String artist;
  final String? album;
  final String? cover;

  PlayTrack({
    required this.url,
    required this.title,
    required this.artist,
    this.album,
    this.cover,
  });
}

class PauseTrack extends PlayerEvent {}

class ResumeTrack extends PlayerEvent {} // 👈 Agregado

class StopTrack extends PlayerEvent {}

class PlayerBloc extends Bloc<PlayerEvent, void> {
  final AudioPlayerHandler handler;

  PlayerBloc(this.handler) : super(null) {
    on<PlayTrack>((event, emit) async {
      print("Playing track: ${event.url}");
      await handler.playMedia(
        event.url,
        title: event.title,
        artist: event.artist,
        album: event.album,
        cover: event.cover,
      );
    });

    on<PauseTrack>((event, emit) => handler.pause());
    on<ResumeTrack>((event, emit) => handler.play()); // 👈 Manejador
    on<StopTrack>((event, emit) => handler.stop());
  }
}
