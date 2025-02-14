class VideoDetails {
  final String id;
  final String text;
  final String thumbnail;

  VideoDetails({required this.id, required this.text, required this.thumbnail});

  factory VideoDetails.fromJson(Map<String, dynamic> json) {
    return VideoDetails(
      id: json['id'],
      text: json['title'],
      thumbnail: json['thumbnail'] ?? "",
    );
  }
}
