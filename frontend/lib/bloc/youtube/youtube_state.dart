import '../../models/video_details.dart';

abstract class YoutubeState {}

class YoutubeInitialState extends YoutubeState {}

class YoutubeLoadingState extends YoutubeState {}

class YoutubeLoadedState extends YoutubeState {
  final List<VideoDetails> videos;
  YoutubeLoadedState({required this.videos});
}

class YoutubeFailureState extends YoutubeState {
  final String error;
  YoutubeFailureState({required this.error});
}
