// lib/audio_handler.dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.playbackEventStream.listen(_broadcastState);

    playbackState.add(
      PlaybackState(
        controls: [],
        androidCompactActionIndices: [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }

  Future<void> playMedia(
    String url, {
    String title = "Título desconocido",
    String artist = "Artista desconocido",
    String? album,
    String? cover,
  }) async {
    // 🔴 Primero añadimos el MediaItem antes de reproducir
    mediaItem.add(
      MediaItem(
        id: url,
        title: title,
        artist: artist,
        album: album,
        artUri: cover != null ? Uri.parse(cover) : null,
        duration:
            null, // Puedes establecer la duración más adelante si la conoces
      ),
    );

    await _player.setUrl(url);
    await _player.play();
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
