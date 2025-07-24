// lib/ui/player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokey_music/models/music_model.dart';
import 'package:pokey_music/ui/main_scaffold.dart'; // 👈 nuevo
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

    return MainScaffold(
      currentIndex: 0,
      child: SafeArea(
        child: FutureBuilder<List<Music>>(
          future: futureMusic,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Cargando música..."));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay música disponible"));
            }

            final musicList = snapshot.data!;
            final filteredList = musicList
                .where((track) => track.fileUrl != null)
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // espacio para el miniplayer
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final track = filteredList[index];
                final url = track.fileUrl?.startsWith("http") == true
                    ? track.fileUrl
                    : "$baseUrl${track.fileUrl ?? ''}";

                return ListTile(
                  leading: Image.network(track.cover ?? ''),
                  title: Text(track.title ?? ''),
                  subtitle: Text(track.artist ?? ''),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
