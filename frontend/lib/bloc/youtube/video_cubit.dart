import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoState extends Equatable {
  final bool isPlaying;
  final Duration currentPosition;

  const VideoState({
    required this.isPlaying,
    required this.currentPosition,
  });

  @override
  List<Object> get props => [isPlaying, currentPosition];
}

class VideoCubit extends Cubit<VideoState> {
  VideoCubit()
      : super(const VideoState(
          isPlaying: false,
          currentPosition: Duration.zero,
        ));

  void updatePlayingState(bool isPlaying) {
    emit(VideoState(
        isPlaying: isPlaying, currentPosition: state.currentPosition));
  }

  void updateSeekTime(Duration position) {
    print("position ${state.isPlaying} $position");
    emit(VideoState(isPlaying: state.isPlaying, currentPosition: position));
  }
}
