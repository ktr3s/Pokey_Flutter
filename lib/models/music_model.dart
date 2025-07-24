class Music {
  final int? id;
  final String? title;
  final String? artist;
  final String? album;
  final String? cover;
  final String? fullQuery;
  final String? fileUrl;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.fullQuery,
    required this.fileUrl,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      cover: json['cover'],
      fullQuery: json['full_query'],
      fileUrl: json['file_url'],
    );
  }
}
