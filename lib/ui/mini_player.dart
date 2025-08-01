import 'package:flutter/material.dart';
import 'dart:ui'; // para BackdropFilter
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokey_music/bloc/player_bloc.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with TickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final handler = context.read<PlayerBloc>().handler;

    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return StreamBuilder<PlaybackState>(
          stream: handler.playbackState,
          builder: (context, stateSnapshot) {
            final state = stateSnapshot.data;
            final isPlaying = state?.playing ?? false;
            final currentPos = state?.updatePosition ?? Duration.zero;
            final duration = mediaItem.duration ?? Duration.zero;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => isExpanded = !isExpanded);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Material(
                      type: MaterialType.transparency,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fila 1: carátula + info + play/pause
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      mediaItem.artUri?.toString() ?? '',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.music_note,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mediaItem.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '${mediaItem.artist ?? ''} — ${mediaItem.album ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 32,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () {
                                      final bloc = context.read<PlayerBloc>();
                                      if (isPlaying) {
                                        bloc.add(PauseTrack());
                                      } else {
                                        bloc.add(ResumeTrack());
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // Animación de expansión
                              if (isExpanded) ...[
                                const SizedBox(height: 8),

                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: duration.inMilliseconds == 0
                                        ? 0
                                        : currentPos.inMilliseconds.toDouble(),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, value, child) {
                                    return Column(
                                      children: [
                                        SliderTheme(
                                          data: SliderTheme.of(context)
                                              .copyWith(
                                                trackHeight: 2,
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                      enabledThumbRadius: 4,
                                                    ),
                                              ),
                                          child: Slider(
                                            value: value.clamp(
                                              0,
                                              duration.inMilliseconds
                                                  .toDouble(),
                                            ),
                                            max: duration.inMilliseconds
                                                .toDouble(),
                                            onChanged: (v) {
                                              handler.seek(
                                                Duration(
                                                  milliseconds: v.toInt(),
                                                ),
                                              );
                                            },
                                            activeColor: Colors.black87,
                                            inactiveColor: Colors.black26,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDuration(
                                                Duration(
                                                  milliseconds: value.toInt(),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(duration),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Controles extra
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_previous,
                                        size: 28,
                                      ),
                                      onPressed: handler.skipToPrevious,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isPlaying
                                            ? Icons.pause_circle
                                            : Icons.play_circle,
                                        size: 36,
                                      ),
                                      onPressed: () {
                                        final bloc = context.read<PlayerBloc>();
                                        if (isPlaying) {
                                          bloc.add(PauseTrack());
                                        } else {
                                          bloc.add(ResumeTrack());
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_next,
                                        size: 28,
                                      ),
                                      onPressed: handler.skipToNext,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
