import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokey_music/models/music_model.dart';
import 'package:pokey_music/ui/main_scaffold.dart';
import '../bloc/player_bloc.dart';
import '../repository/music_repository.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final repository = MusicRepository();
  late Future<List<Music>> futureMusic;
  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    futureMusic = repository.fetchMusicList();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final theme = Theme.of(context);

    return MainScaffold(
      currentIndex: 0,
      child: SafeArea(
        child: FutureBuilder<List<Music>>(
          future: futureMusic,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay música disponible"));
            }

            final musicList = snapshot.data!
                .where((track) => track.fileUrl != null)
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 16),
              itemCount: musicList.length,
              itemBuilder: (context, index) {
                final track = musicList[index];
                final url = track.fileUrl?.startsWith("http") == true
                    ? track.fileUrl
                    : "$baseUrl${track.fileUrl ?? ''}";

                return InkWell(
                  onTap: () {
                    bloc.add(
                      PlayTrack(
                        url: url ?? '',
                        title: track.title ?? 'Sin título',
                        artist: track.artist ?? 'Desconocido',
                        album: track.album,
                        cover: track.cover,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            track.cover ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white70,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title ?? 'Sin título',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                track.artist ?? 'Desconocido',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
