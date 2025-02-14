class Room {
  final String id;
  final String name;
  final String hostId;
  final String? videoId;
  final List<String>? participents;
  final int? seekTime;
  final bool? isPlaying;

  Room(
      {required this.id,
      required this.name,
      required this.hostId,
      this.videoId,
      this.participents,
      this.seekTime,
      this.isPlaying});

  Room copyWith(
      {String? id,
      String? name,
      String? hostId,
      String? videoId,
      List<String>? participents,
      int? seekTime,
      bool? isPlaying}) {
    return Room(
        id: id ?? this.id,
        name: name ?? this.name,
        hostId: hostId ?? this.hostId,
        videoId: videoId ?? this.videoId,
        participents: participents ?? this.participents,
        seekTime: seekTime ?? this.seekTime,
        isPlaying: isPlaying ?? this.isPlaying);
  }
}
