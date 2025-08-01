import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokey_music/models/music_model.dart';
import 'package:pokey_music/ui/main_scaffold.dart';
import '../bloc/player_bloc.dart';
import '../repository/music_repository.dart';
import '../utils/token_storage.dart';
import 'login_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final repository = MusicRepository();
  late Future<List<Music>> futureMusic;
  List<Music> fullMusicList = [];
  List<Music> filteredMusicList = [];
  final TextEditingController searchController = TextEditingController();
  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    futureMusic = repository.fetchMusicList().then((list) {
      final withUrls = list.where((track) => track.fileUrl != null).toList();
      fullMusicList = withUrls;
      filteredMusicList = withUrls;
      return withUrls;
    });
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredMusicList = fullMusicList.where((track) {
        final title = track.title?.toLowerCase() ?? '';
        final artist = track.artist?.toLowerCase() ?? '';
        return title.contains(query) || artist.contains(query);
      }).toList();
    });
  }

  void _logout() async {
    await TokenStorage.clearToken();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    final theme = Theme.of(context);

    return MainScaffold(
      currentIndex: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Header con campo de búsqueda + cerrar sesión
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Lista de canciones
            Expanded(
              child: FutureBuilder<List<Music>>(
                future: futureMusic,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (filteredMusicList.isEmpty) {
                    return const Center(child: Text("No hay resultados"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100, top: 0),
                    itemCount: filteredMusicList.length,
                    itemBuilder: (context, index) {
                      final track = filteredMusicList[index];
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      track.artist ?? 'Desconocido',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
          ],
        ),
      ),
    );
  }
}
